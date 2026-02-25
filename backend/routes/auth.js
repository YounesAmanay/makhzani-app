// backend/routes/auth.js
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const db = require('../models');

const { sendOtpLimiter, verifyOtpLimiter } = require('../middleware/rateLimiter');

// OTP storage — uses Redis when available, falls back to in-memory Map
const { getRedisClient, isRedisAvailable } = require('../config/redis');
const otpStore = new Map(); // Fallback only

const OTP_TTL_SECONDS = 5 * 60; // 5 minutes

async function storeOtp(phoneNumber, otpData) {
  if (isRedisAvailable()) {
    const client = await getRedisClient();
    await client.set(`otp:${phoneNumber}`, JSON.stringify(otpData), { EX: OTP_TTL_SECONDS });
  } else {
    otpStore.set(phoneNumber, otpData);
  }
}

async function getOtp(phoneNumber) {
  if (isRedisAvailable()) {
    const client = await getRedisClient();
    const data = await client.get(`otp:${phoneNumber}`);
    return data ? JSON.parse(data) : null;
  }
  return otpStore.get(phoneNumber) || null;
}

async function deleteOtp(phoneNumber) {
  if (isRedisAvailable()) {
    const client = await getRedisClient();
    await client.del(`otp:${phoneNumber}`);
  } else {
    otpStore.delete(phoneNumber);
  }
}

// Rate limiting for auth endpoints (per phone number)
const authRateLimits = {};

function checkAuthRateLimit(phoneNumber, endpoint) {
  const key = `${endpoint}:${phoneNumber}`;
  const now = Date.now();
  const windowMs = 15 * 60 * 1000; // 15-minute window
  const maxAttempts = endpoint === 'send-otp' ? 5 : 10; // 5 OTP sends, 10 verifications per window

  if (!authRateLimits[key] || now > authRateLimits[key].resetAt) {
    authRateLimits[key] = { count: 1, resetAt: now + windowMs };
    return null;
  }

  authRateLimits[key].count++;

  if (authRateLimits[key].count > maxAttempts) {
    const retryAfter = Math.ceil((authRateLimits[key].resetAt - now) / 1000);
    return retryAfter;
  }

  return null;
}

// Clean up expired rate limit entries every 30 minutes
setInterval(() => {
  const now = Date.now();
  for (const key of Object.keys(authRateLimits)) {
    if (now > authRateLimits[key].resetAt) {
      delete authRateLimits[key];
    }
  }
}, 30 * 60 * 1000);

// Generate random 4-digit OTP
function generateOTP() {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

// Generate JWT token
function generateToken(merchant) {
  return jwt.sign(
    { 
      id: merchant.id, 
      phone: merchant.phone_number,
      shop_name: merchant.shop_name 
    },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );
}

// Validation middleware
const validatePhone = [
  body('phone_number')
    .matches(/^\+212[5-7]\d{8}$/)
    .withMessage('Invalid Morocco phone number. Use +212XXXXXXXXX format')
];

const validateOTP = [
  body('phone_number')
    .matches(/^\+212[5-7]\d{8}$/)
    .withMessage('Invalid Morocco phone number'),
  body('otp')
    .isLength({ min: 4, max: 4 })
    .isNumeric()
    .withMessage('OTP must be 4 digits')
];

// Error handling middleware
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

/**
 * POST /api/auth/send-otp
 * Send OTP to merchant's phone number
 */
router.post('/send-otp', sendOtpLimiter, validatePhone, handleValidationErrors, async (req, res) => {
  try {
    const { phone_number } = req.body;

    // Rate limit check
    const retryAfter = checkAuthRateLimit(phone_number, 'send-otp');
    if (retryAfter) {
      return res.status(429).json({
        success: false,
        message: 'Too many OTP requests. Please try again later.',
        code: 'RATE_LIMITED',
        retry_after_seconds: retryAfter
      });
    }

    console.log(`📱 OTP request for: ${phone_number}`);

    // Check if merchant exists
    let merchant = await db.Merchant.findOne({
      where: { phone_number }
    });

    // Generate OTP
    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store OTP (Redis with TTL, or in-memory fallback)
    await storeOtp(phone_number, {
      otp,
      expiresAt: expiresAt.toISOString(),
      attempts: 0
    });

    // Send SMS via Infobip only when ENABLE_SMS=true
    if (process.env.ENABLE_SMS === 'true') {
      const { Infobip, AuthType } = require('@infobip-api/sdk');
      const infobip = new Infobip({
        baseUrl: process.env.INFOBIP_BASE_URL,
        apiKey: process.env.INFOBIP_API_KEY,
        authType: AuthType.ApiKey,
      });
      await infobip.channels.sms.send({
        messages: [{
          destinations: [{ to: phone_number }],
          from: process.env.INFOBIP_SENDER,
          text: `Your Makhzani verification code: ${otp}`,
        }],
      });
    }
    // Always log OTP — readable via pm2 logs on server
    console.log(`🔢 OTP for ${phone_number}: ${otp}`);

    res.json({
      success: true,
      message: 'OTP sent successfully',
      data: {
        phone_number,
        merchant_exists: !!merchant
      }
    });

  } catch (error) {
    console.error('❌ Send OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send OTP',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/auth/verify-otp
 * Verify OTP and return JWT token
 */
router.post('/verify-otp', verifyOtpLimiter, validateOTP, handleValidationErrors, async (req, res) => {
  try {
    const { phone_number, otp } = req.body;

    // Rate limit check
    const retryAfter = checkAuthRateLimit(phone_number, 'verify-otp');
    if (retryAfter) {
      return res.status(429).json({
        success: false,
        message: 'Too many verification attempts. Please try again later.',
        code: 'RATE_LIMITED',
        retry_after_seconds: retryAfter
      });
    }

    console.log(`🔐 OTP verification for: ${phone_number}`);

    // Check stored OTP
    const storedOTP = await getOtp(phone_number);

    if (!storedOTP) {
      return res.status(400).json({
        success: false,
        message: 'No OTP found. Please request a new one.',
        code: 'OTP_NOT_FOUND'
      });
    }

    // Check expiration
    if (new Date() > new Date(storedOTP.expiresAt)) {
      await deleteOtp(phone_number);
      return res.status(400).json({
        success: false,
        message: 'OTP has expired. Please request a new one.',
        code: 'OTP_EXPIRED'
      });
    }

    // Check attempts (prevent brute force)
    if (storedOTP.attempts >= 3) {
      await deleteOtp(phone_number);
      return res.status(429).json({
        success: false,
        message: 'Too many failed attempts. Please request a new OTP.',
        code: 'TOO_MANY_ATTEMPTS'
      });
    }

    // Verify OTP
    if (storedOTP.otp !== otp) {
      storedOTP.attempts++;
      await storeOtp(phone_number, storedOTP);
      
      return res.status(400).json({
        success: false,
        message: 'Invalid OTP. Please try again.',
        code: 'INVALID_OTP',
        attempts_remaining: 3 - storedOTP.attempts
      });
    }

    // OTP is valid - clean up
    await deleteOtp(phone_number);

    // Find or create merchant
    let merchant = await db.Merchant.findOne({
      where: { phone_number }
    });

    let isNewUser = false;

    if (!merchant) {
      // New merchant - create basic profile
      merchant = await db.Merchant.create({
        phone_number,
        name: 'New Merchant', // Will be updated in onboarding
        shop_name: 'My Shop', // Will be updated in onboarding
        otp_verified: true
      });
      isNewUser = true;
      console.log(`👤 Created new merchant: ${merchant.id}`);
    } else {
      // Existing merchant - mark as verified and update last login
      await merchant.update({
        otp_verified: true,
        last_login: new Date()
      });
      console.log(`🔄 Updated existing merchant: ${merchant.id}`);
    }

    // Generate JWT token
    const token = generateToken(merchant);

    console.log(`✅ Authentication successful for: ${phone_number}`);

    res.json({
      success: true,
      message: 'Authentication successful',
      data: {
        token,
        merchant: {
          id: merchant.id,
          phone_number: merchant.phone_number,
          name: merchant.name,
          shop_name: merchant.shop_name,
          region: merchant.region,
          subscription_status: merchant.subscription_status,
          trial_ends_at: merchant.trial_ends_at,
          is_new_user: isNewUser
        }
      }
    });

  } catch (error) {
    console.error('❌ Verify OTP error:', error);
    res.status(500).json({
      success: false,
      message: 'Authentication failed',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/auth/refresh-token
 * Refresh JWT token
 */
router.post('/refresh-token', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const token = authHeader.substring(7);
    
    // Verify current token (even if expired, we'll check the payload)
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        // Token expired, but we can still decode the payload
        decoded = jwt.decode(token);
      } else {
        throw err;
      }
    }

    if (!decoded || !decoded.id) {
      return res.status(401).json({
        success: false,
        message: 'Invalid token'
      });
    }

    // Get current merchant data
    const merchant = await db.Merchant.findByPk(decoded.id);
    
    if (!merchant || !merchant.is_active) {
      return res.status(401).json({
        success: false,
        message: 'Merchant not found or inactive'
      });
    }

    // Generate new token
    const newToken = generateToken(merchant);

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        token: newToken,
        merchant: {
          id: merchant.id,
          phone_number: merchant.phone_number,
          name: merchant.name,
          shop_name: merchant.shop_name,
          region: merchant.region,
          subscription_status: merchant.subscription_status
        }
      }
    });

  } catch (error) {
    console.error('❌ Refresh token error:', error);
    res.status(401).json({
      success: false,
      message: 'Token refresh failed',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Invalid token'
    });
  }
});

module.exports = router;
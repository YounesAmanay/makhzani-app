// backend/middleware/rateLimiter.js
//
// Rate limiters using express-rate-limit (in-memory, no Redis dependency).
// These act as a hard baseline regardless of Redis availability.

const rateLimit = require('express-rate-limit');

/**
 * Global API limiter — protects all routes from basic DDoS.
 * 100 requests per minute per IP.
 */
const apiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many requests. Please try again in a minute.',
  },
});

/**
 * OTP send limiter — prevents SMS/OTP abuse.
 * 5 requests per 15 minutes per IP.
 */
const sendOtpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many OTP requests. Please wait 15 minutes before trying again.',
  },
});

/**
 * OTP verify limiter — prevents brute-force OTP guessing.
 * 10 attempts per 15 minutes per IP.
 */
const verifyOtpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many verification attempts. Please wait 15 minutes before trying again.',
  },
});

module.exports = { apiLimiter, sendOtpLimiter, verifyOtpLimiter };

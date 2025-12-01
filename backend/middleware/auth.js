const jwt = require('jsonwebtoken');
const db = require('../models');

/**
 * Middleware to verify JWT token and authenticate requests
 */
const authenticateToken = async (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. No token provided.',
        code: 'NO_TOKEN'
      });
    }

    // Extract token (remove "Bearer " prefix)
    const token = authHeader.substring(7);

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get merchant from database
    const merchant = await db.Merchant.findByPk(decoded.id);
    
    if (!merchant) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Merchant not found.',
        code: 'MERCHANT_NOT_FOUND'
      });
    }

    if (!merchant.is_active) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Account is inactive.',
        code: 'ACCOUNT_INACTIVE'
      });
    }

    if (!merchant.otp_verified) {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Phone number not verified.',
        code: 'PHONE_NOT_VERIFIED'
      });
    }

    // Add merchant to request object
    req.merchant = merchant;
    req.merchantId = merchant.id;
    
    next();

  } catch (error) {
    console.error('🔐 Auth middleware error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Invalid token.',
        code: 'INVALID_TOKEN'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Access denied. Token expired.',
        code: 'TOKEN_EXPIRED'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Authentication error',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
};

/**
 * Middleware to check subscription status
 */
const checkSubscription = (req, res, next) => {
  const merchant = req.merchant;
  
  if (!merchant) {
    return res.status(401).json({
      success: false,
      message: 'Authentication required'
    });
  }

  // Check if trial has expired and no paid subscription
  if (merchant.subscription_status === 'trial' && new Date() > merchant.trial_ends_at) {
    return res.status(402).json({
      success: false,
      message: 'Trial period has expired. Please upgrade to continue.',
      code: 'TRIAL_EXPIRED',
      trial_ends_at: merchant.trial_ends_at
    });
  }

  if (merchant.subscription_status === 'suspended') {
    return res.status(402).json({
      success: false,
      message: 'Account subscription is suspended. Please contact support.',
      code: 'SUBSCRIPTION_SUSPENDED'
    });
  }

  next();
};

/**
 * Optional authentication - doesn't fail if no token
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next(); // Continue without authentication
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const merchant = await db.Merchant.findByPk(decoded.id);
    
    if (merchant && merchant.is_active) {
      req.merchant = merchant;
      req.merchantId = merchant.id;
    }
    
    next();

  } catch (error) {
    // Ignore auth errors for optional auth
    next();
  }
};

module.exports = {
  authenticateToken,
  checkSubscription,
  optionalAuth
};
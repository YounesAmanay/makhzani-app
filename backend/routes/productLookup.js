/**
 * Product Lookup Routes
 *
 * GET /api/products/lookup?barcode={code}
 *
 * Mounted before /:id routes in server.js to prevent route shadowing.
 */

const express = require('express');
const router = express.Router();

const { authenticateToken } = require('../middleware/auth');
const { lookupBarcode } = require('../services/barcodeLookupService');
const db = require('../models');

// ---------------------------------------------------------------------------
// Per-merchant rate limiter: 60 lookups / hour (in-memory)
// ---------------------------------------------------------------------------

const lookupCounts = {}; // { merchantId: { count, resetAt } }

function checkRateLimit(merchantId) {
  const now = Date.now();
  const entry = lookupCounts[merchantId];

  if (!entry || entry.resetAt < now) {
    lookupCounts[merchantId] = { count: 1, resetAt: now + 3_600_000 };
    return true;
  }

  if (entry.count >= 60) return false;

  entry.count++;
  return true;
}

// Clean up expired entries every hour to prevent memory leak
setInterval(() => {
  const now = Date.now();
  for (const id of Object.keys(lookupCounts)) {
    if (lookupCounts[id].resetAt < now) delete lookupCounts[id];
  }
}, 3_600_000);

// ---------------------------------------------------------------------------
// Barcode validation
// ---------------------------------------------------------------------------

const BARCODE_REGEX = /^\d{8,14}$/;

function validateBarcode(barcode) {
  if (!barcode) return 'Barcode is required';
  if (!BARCODE_REGEX.test(barcode)) return 'Barcode must be 8-14 digits';
  return null;
}

// ---------------------------------------------------------------------------
// GET /by-barcode?barcode={code}  — exact match against merchant's own inventory
// ---------------------------------------------------------------------------

router.get('/by-barcode', authenticateToken, async (req, res) => {
  const { barcode } = req.query;

  if (!barcode) {
    return res.status(400).json({ success: false, message: 'barcode is required' });
  }

  try {
    const product = await db.Product.findOne({
      where: {
        merchant_id: req.merchantId,
        barcode: barcode.trim(),
        is_active: true,
      },
      attributes: [
        'id', 'name', 'current_stock', 'reorder_threshold',
        'unit', 'barcode', 'price', 'cost_price', 'category_id',
      ],
    });

    return res.json({ success: true, data: product ? product.toJSON() : null });
  } catch (err) {
    console.error('[ByBarcode]', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ---------------------------------------------------------------------------
// GET /lookup?barcode={code}
// ---------------------------------------------------------------------------

router.get('/lookup', authenticateToken, async (req, res) => {
  const { barcode } = req.query;

  // Validate
  const validationError = validateBarcode(barcode);
  if (validationError) {
    return res.status(400).json({
      success: false,
      message: 'Invalid barcode',
      errors: [{ type: 'field', path: 'barcode', msg: validationError, location: 'query' }],
    });
  }

  // Rate limit
  if (!checkRateLimit(req.merchantId)) {
    return res.status(429).json({
      success: false,
      message: 'Too many lookup requests. Limit is 60 per hour.',
    });
  }

  try {
    const product = await lookupBarcode(barcode.trim());

    if (!product) {
      return res.json({
        success: true,
        data: null,
        message: 'Product not found in any database',
      });
    }

    return res.json({
      success: true,
      data: product,
    });
  } catch (err) {
    console.error('[ProductLookup] Unexpected error:', err);
    return res.status(500).json({
      success: false,
      message: 'Lookup failed, please try again',
    });
  }
});

module.exports = router;

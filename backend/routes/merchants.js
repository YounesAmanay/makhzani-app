// backend/routes/merchants.js
const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');

// Validation middleware
const validateMerchantUpdate = [
  body('name')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be 2-100 characters'),
  body('shop_name')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Shop name must be 2-100 characters'),
  body('address')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Address too long'),
  body('region')
    .optional()
    .isIn(['Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other'])
    .withMessage('Invalid region')
];

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
 * GET /api/merchants/profile
 * Get merchant profile with complete information
 */
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const merchant = await db.Merchant.findByPk(req.merchantId, {
      include: [
        {
          model: db.Supplier,
          as: 'suppliers',
          where: { is_active: true },
          required: false
        },
        {
          model: db.Product,
          as: 'products',
          where: { is_active: true },
          required: false
        }
      ]
    });

    if (!merchant) {
      return res.status(404).json({
        success: false,
        message: 'Merchant not found'
      });
    }

    // Calculate statistics
    const totalProducts = merchant.products.length;
    const lowStockProducts = merchant.products.filter(p => p.current_stock <= p.reorder_threshold).length;
    
    res.json({
      success: true,
      data: {
        merchant: {
          id: merchant.id,
          name: merchant.name,
          shop_name: merchant.shop_name,
          phone_number: merchant.phone_number,
          email: merchant.email,
          address: merchant.address,
          region: merchant.region,
          avatar_url: merchant.avatar_url,
          subscription_status: merchant.subscription_status,
          trial_ends_at: merchant.trial_ends_at,
          last_login: merchant.last_login,
          created_at: merchant.created_at
        },
        statistics: {
          total_products: totalProducts,
          low_stock_products: lowStockProducts,
          total_suppliers: merchant.suppliers.length
        }
      }
    });

  } catch (error) {
    console.error('Error fetching merchant profile:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch profile',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * PUT /api/merchants/profile
 * Update merchant profile
 */
router.put('/profile', authenticateToken, validateMerchantUpdate, handleValidationErrors, async (req, res) => {
  try {
    const { name, shop_name, address, region } = req.body;
    
    const merchant = await db.Merchant.findByPk(req.merchantId);
    
    if (!merchant) {
      return res.status(404).json({
        success: false,
        message: 'Merchant not found'
      });
    }

    // Update fields
    const updateData = {};
    if (name !== undefined) updateData.name = name;
    if (shop_name !== undefined) updateData.shop_name = shop_name;
    if (address !== undefined) updateData.address = address;
    if (region !== undefined) updateData.region = region;

    await merchant.update(updateData);

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        merchant: {
          id: merchant.id,
          name: merchant.name,
          shop_name: merchant.shop_name,
          phone_number: merchant.phone_number,
          address: merchant.address,
          region: merchant.region,
          updated_at: merchant.updated_at
        }
      }
    });

  } catch (error) {
    console.error('Error updating merchant profile:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * GET /api/merchants/dashboard-stats
 * Get dashboard statistics for merchant
 */
router.get('/dashboard-stats', authenticateToken, async (req, res) => {
  try {
    const merchantId = req.merchantId;
    
    // Get counts in parallel
    const [
      totalProducts,
      lowStockProducts,
      totalSuppliers,
      recentOrders,
      totalOrders
    ] = await Promise.all([
      db.Product.count({ where: { merchant_id: merchantId, is_active: true } }),
      db.Product.count({ 
        where: { 
          merchant_id: merchantId, 
          is_active: true,
          current_stock: { [db.Sequelize.Op.lte]: db.Sequelize.col('reorder_threshold') }
        } 
      }),
      db.Supplier.count({ where: { merchant_id: merchantId, is_active: true } }),
      db.PurchaseOrder.findAll({
        where: { merchant_id: merchantId, is_active: true },
        order: [['created_at', 'DESC']],
        limit: 5,
        include: [
          { model: db.Supplier, as: 'supplier', attributes: ['name'] }
        ]
      }),
      db.PurchaseOrder.count({ where: { merchant_id: merchantId, is_active: true } })
    ]);

    // Get low stock products details
    const lowStockProductDetails = await db.Product.findAll({
      where: { 
        merchant_id: merchantId, 
        is_active: true,
        current_stock: { [db.Sequelize.Op.lte]: db.Sequelize.col('reorder_threshold') }
      },
      attributes: ['id', 'name', 'current_stock', 'reorder_threshold', 'unit'],
      limit: 10
    });

    res.json({
      success: true,
      data: {
        overview: {
          total_products: totalProducts,
          low_stock_products: lowStockProducts,
          total_suppliers: totalSuppliers,
          total_orders: totalOrders
        },
        low_stock_items: lowStockProductDetails.map(product => ({
          id: product.id,
          name: product.name,
          current_stock: product.current_stock,
          reorder_threshold: product.reorder_threshold,
          unit: product.unit,
          shortage: product.reorder_threshold - product.current_stock
        })),
        recent_orders: recentOrders.map(order => ({
          id: order.id,
          order_number: order.order_number,
          supplier_name: order.supplier?.name,
          created_at: order.created_at,
          pdf_generated: !!order.pdf_generated_at,
          sent: !!order.sent_at
        }))
      }
    });

  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

// POST /avatar -- upload merchant avatar
const { uploadAvatar } = require('../middleware/upload');

router.post(
  '/avatar',
  authenticateToken,
  (req, res, next) => {
    uploadAvatar.single('avatar')(req, res, (err) => {
      if (err) {
        return res.status(400).json({
          success: false,
          message: err.message || 'File upload failed',
          errors: [{ path: 'avatar', msg: err.message }],
        });
      }
      next();
    });
  },
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'No image file provided',
          errors: [{ path: 'avatar', msg: 'Please select an image file' }],
        });
      }

      const merchant = await db.Merchant.findByPk(req.merchantId);
      if (!merchant) {
        return res.status(404).json({ success: false, message: 'Merchant not found' });
      }

      // Delete old avatar file from disk if it exists
      if (merchant.avatar_url) {
        const oldPath = require('path').join(__dirname, '..', merchant.avatar_url);
        require('fs').unlink(oldPath, () => {}); // non-fatal
      }

      const avatarUrl = `/uploads/avatars/${req.file.filename}`;

      try {
        await merchant.update({ avatar_url: avatarUrl });
      } catch (dbError) {
        // DB update failed — clean up the newly uploaded file
        const newPath = require('path').join(__dirname, '..', avatarUrl);
        require('fs').unlink(newPath, () => {});
        throw dbError;
      }

      res.json({ success: true, data: { avatar_url: avatarUrl } });
    } catch (error) {
      console.error('Error uploading merchant avatar:', error);
      res.status(500).json({ success: false, message: 'Failed to upload avatar' });
    }
  }
);

/**
 * POST /api/merchants/fcm-token
 * Register or update the merchant's FCM device token for push notifications.
 */
router.post('/fcm-token', authenticateToken, async (req, res) => {
  try {
    const { token } = req.body;

    if (!token || typeof token !== 'string' || token.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'FCM token is required' });
    }

    await db.Merchant.update(
      { fcm_token: token.trim() },
      { where: { id: req.merchantId } }
    );

    res.json({ success: true, message: 'FCM token registered' });
  } catch (error) {
    console.error('Error registering FCM token:', error);
    res.status(500).json({ success: false, message: 'Failed to register FCM token' });
  }
});

module.exports = router;
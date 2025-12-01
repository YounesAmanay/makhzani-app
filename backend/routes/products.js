// backend/routes/products.js
const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');

// Validation middleware
const validateProduct = [
  body('name')
    .notEmpty()
    .isLength({ min: 2, max: 100 })
    .withMessage('Product name must be 2-100 characters'),
  body('current_stock')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Stock must be a positive integer'),
  body('reorder_threshold')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Reorder threshold must be a positive integer'),
  body('unit')
    .optional()
    .isIn(['piece', 'kg', 'liter', 'box', 'carton', 'bottle'])
    .withMessage('Invalid unit type'),
  body('barcode')
    .optional()
    .isLength({ min: 8, max: 50 })
    .withMessage('Barcode must be 8-50 characters'),
  body('price')
    .optional()
    .isDecimal({ decimal_digits: '0,2' })
    .withMessage('Price must be a valid decimal with max 2 decimal places')
];

const validateProductUpdate = [
  body('name')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Product name must be 2-100 characters'),
  body('current_stock')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Stock must be a positive integer'),
  body('reorder_threshold')
    .optional()
    .isInt({ min: 0 })
    .withMessage('Reorder threshold must be a positive integer'),
  body('unit')
    .optional()
    .isIn(['piece', 'kg', 'liter', 'box', 'carton', 'bottle'])
    .withMessage('Invalid unit type'),
  body('barcode')
    .optional()
    .isLength({ min: 8, max: 50 })
    .withMessage('Barcode must be 8-50 characters'),
  body('price')
    .optional()
    .isDecimal({ decimal_digits: '0,2' })
    .withMessage('Price must be a valid decimal')
];

const validateQuery = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('search')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Search term too long'),
  query('low_stock')
    .optional()
    .isBoolean()
    .withMessage('Low stock filter must be boolean')
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
 * GET /api/products
 * Get merchant's inventory with pagination and filtering
 */
router.get('/', authenticateToken, validateQuery, handleValidationErrors, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, low_stock } = req.query;
    const offset = (page - 1) * limit;

    // Build where conditions
    const whereConditions = {
      merchant_id: req.merchantId,
      is_active: true
    };

    // Add search filter
    if (search) {
      whereConditions[db.Sequelize.Op.or] = [
        { name: { [db.Sequelize.Op.like]: `%${search}%` } },
        { barcode: { [db.Sequelize.Op.like]: `%${search}%` } }
      ];
    }

    // Add low stock filter
    if (low_stock === 'true') {
      whereConditions.current_stock = {
        [db.Sequelize.Op.lte]: db.Sequelize.col('reorder_threshold')
      };
    }

    const { count, rows: products } = await db.Product.findAndCountAll({
      where: whereConditions,
      order: [['name', 'ASC']],
      limit: parseInt(limit),
      offset: parseInt(offset),
      attributes: [
        'id', 'name', 'current_stock', 'reorder_threshold', 
        'unit', 'barcode', 'price', 'created_at', 'updated_at'
      ]
    });

    // Calculate pagination info
    const totalPages = Math.ceil(count / limit);
    const hasNextPage = page < totalPages;
    const hasPrevPage = page > 1;

    res.json({
      success: true,
      data: {
        products: products.map(product => ({
          ...product.toJSON(),
          needs_reorder: product.current_stock <= product.reorder_threshold,
          stock_status: product.current_stock <= product.reorder_threshold ? 'low' : 'ok'
        })),
        pagination: {
          current_page: parseInt(page),
          total_pages: totalPages,
          total_products: count,
          has_next_page: hasNextPage,
          has_prev_page: hasPrevPage,
          per_page: parseInt(limit)
        }
      }
    });

  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/products
 * Add new product to inventory
 */
router.post('/', authenticateToken, checkSubscription, validateProduct, handleValidationErrors, async (req, res) => {
  try {
    const { name, current_stock = 0, reorder_threshold = 5, unit = 'piece', barcode, price } = req.body;

    // Check for duplicate product name for this merchant
    const existingProduct = await db.Product.findOne({
      where: {
        merchant_id: req.merchantId,
        name: name.trim(),
        is_active: true
      }
    });

    if (existingProduct) {
      return res.status(400).json({
        success: false,
        message: 'Product with this name already exists',
        code: 'DUPLICATE_PRODUCT_NAME'
      });
    }

    // Check for duplicate barcode if provided
    if (barcode) {
      const existingBarcode = await db.Product.findOne({
        where: {
          merchant_id: req.merchantId,
          barcode: barcode.trim(),
          is_active: true
        }
      });

      if (existingBarcode) {
        return res.status(400).json({
          success: false,
          message: 'Product with this barcode already exists',
          code: 'DUPLICATE_BARCODE'
        });
      }
    }

    const product = await db.Product.create({
      merchant_id: req.merchantId,
      name: name.trim(),
      current_stock,
      reorder_threshold,
      unit,
      barcode: barcode?.trim() || null,
      price: price || null
    });

    console.log(`📦 New product created: ${product.name} (${product.id})`);

    res.status(201).json({
      success: true,
      message: 'Product added successfully',
      data: {
        product: {
          id: product.id,
          name: product.name,
          current_stock: product.current_stock,
          reorder_threshold: product.reorder_threshold,
          unit: product.unit,
          barcode: product.barcode,
          price: product.price,
          needs_reorder: product.current_stock <= product.reorder_threshold,
          created_at: product.created_at
        }
      }
    });

  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add product',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * GET /api/products/:id
 * Get specific product details
 */
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const product = await db.Product.findOne({
      where: {
        id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true
      }
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    res.json({
      success: true,
      data: {
        product: {
          ...product.toJSON(),
          needs_reorder: product.current_stock <= product.reorder_threshold,
          stock_status: product.current_stock <= product.reorder_threshold ? 'low' : 'ok'
        }
      }
    });

  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch product',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * PUT /api/products/:id
 * Update product information
 */
router.put('/:id', authenticateToken, checkSubscription, validateProductUpdate, handleValidationErrors, async (req, res) => {
  try {
    const product = await db.Product.findOne({
      where: {
        id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true
      }
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const { name, current_stock, reorder_threshold, unit, barcode, price } = req.body;

    // Check for duplicate name if name is being updated
    if (name && name !== product.name) {
      const existingProduct = await db.Product.findOne({
        where: {
          merchant_id: req.merchantId,
          name: name.trim(),
          is_active: true,
          id: { [db.Sequelize.Op.ne]: product.id }
        }
      });

      if (existingProduct) {
        return res.status(400).json({
          success: false,
          message: 'Another product with this name already exists',
          code: 'DUPLICATE_PRODUCT_NAME'
        });
      }
    }

    // Check for duplicate barcode if barcode is being updated
    if (barcode && barcode !== product.barcode) {
      const existingBarcode = await db.Product.findOne({
        where: {
          merchant_id: req.merchantId,
          barcode: barcode.trim(),
          is_active: true,
          id: { [db.Sequelize.Op.ne]: product.id }
        }
      });

      if (existingBarcode) {
        return res.status(400).json({
          success: false,
          message: 'Another product with this barcode already exists',
          code: 'DUPLICATE_BARCODE'
        });
      }
    }

    // Update product
    const updateData = {};
    if (name !== undefined) updateData.name = name.trim();
    if (current_stock !== undefined) updateData.current_stock = current_stock;
    if (reorder_threshold !== undefined) updateData.reorder_threshold = reorder_threshold;
    if (unit !== undefined) updateData.unit = unit;
    if (barcode !== undefined) updateData.barcode = barcode?.trim() || null;
    if (price !== undefined) updateData.price = price || null;

    await product.update(updateData);

    console.log(`📝 Product updated: ${product.name} (${product.id})`);

    res.json({
      success: true,
      message: 'Product updated successfully',
      data: {
        product: {
          ...product.toJSON(),
          needs_reorder: product.current_stock <= product.reorder_threshold,
          stock_status: product.current_stock <= product.reorder_threshold ? 'low' : 'ok'
        }
      }
    });

  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update product',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * DELETE /api/products/:id
 * Soft delete product (mark as inactive)
 */
router.delete('/:id', authenticateToken, checkSubscription, async (req, res) => {
  try {
    const product = await db.Product.findOne({
      where: {
        id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true
      }
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Soft delete
    await product.update({ is_active: false });

    console.log(`🗑️ Product deleted: ${product.name} (${product.id})`);

    res.json({
      success: true,
      message: 'Product deleted successfully'
    });

  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete product',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/products/:id/adjust-stock
 * Adjust product stock (add or subtract)
 */
router.post('/:id/adjust-stock', authenticateToken, checkSubscription, async (req, res) => {
  try {
    const { adjustment, reason } = req.body;

    if (!adjustment || !Number.isInteger(adjustment)) {
      return res.status(400).json({
        success: false,
        message: 'Adjustment must be a non-zero integer'
      });
    }

    const product = await db.Product.findOne({
      where: {
        id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true
      }
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const newStock = product.current_stock + adjustment;

    if (newStock < 0) {
      return res.status(400).json({
        success: false,
        message: 'Stock cannot be negative',
        current_stock: product.current_stock,
        attempted_adjustment: adjustment
      });
    }

    const oldStock = product.current_stock;
    await product.update({ current_stock: newStock });

    console.log(`📊 Stock adjusted: ${product.name} ${oldStock} → ${newStock} (${adjustment > 0 ? '+' : ''}${adjustment})`);

    res.json({
      success: true,
      message: 'Stock adjusted successfully',
      data: {
        product: {
          id: product.id,
          name: product.name,
          old_stock: oldStock,
          new_stock: newStock,
          adjustment: adjustment,
          reason: reason || null,
          needs_reorder: newStock <= product.reorder_threshold
        }
      }
    });

  } catch (error) {
    console.error('Error adjusting stock:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to adjust stock',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
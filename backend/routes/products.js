// backend/routes/products.js
const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');
const { logStockTransaction } = require('../utils/stockLogger');
const { notifyLowStock } = require('../utils/notificationService');

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
    .withMessage('Price must be a valid decimal with max 2 decimal places'),
  body('cost_price')
    .optional({ nullable: true })
    .isFloat({ min: 0 })
    .withMessage('Cost price must be a positive number'),
  body('category_id')
    .optional({ values: 'null' })
    .isUUID()
    .withMessage('Invalid category ID')
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
    .withMessage('Price must be a valid decimal'),
  body('cost_price')
    .optional({ nullable: true })
    .isFloat({ min: 0 })
    .withMessage('Cost price must be a positive number'),
  body('category_id')
    .optional({ values: 'null' })
    .isUUID()
    .withMessage('Invalid category ID')
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
    .withMessage('Low stock filter must be boolean'),
  query('category_id')
    .optional()
    .isUUID()
    .withMessage('Invalid category ID')
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
    const { page = 1, limit = 20, search, low_stock, category_id } = req.query;
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

    // Add category filter
    if (category_id) {
      whereConditions.category_id = category_id;
    }

    const { count, rows: products } = await db.Product.findAndCountAll({
      where: whereConditions,
      order: [['name', 'ASC']],
      limit: parseInt(limit),
      offset: parseInt(offset),
      attributes: [
        'id', 'name', 'current_stock', 'reorder_threshold',
        'unit', 'barcode', 'price', 'cost_price', 'category_id', 'created_at', 'updated_at'
      ],
      include: [{
        model: db.Category,
        as: 'category',
        attributes: ['id', 'name', 'color', 'icon'],
        required: false,
      }]
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
          created_at: product.createdAt,
          updated_at: product.updatedAt,
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
    const { name, current_stock = 0, reorder_threshold = 5, unit = 'piece', barcode, price, cost_price, category_id } = req.body;

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
      price: price || null,
      cost_price: cost_price != null ? cost_price : null,
      category_id: category_id || null,
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
          cost_price: product.cost_price,
          category_id: product.category_id,
          needs_reorder: product.current_stock <= product.reorder_threshold,
          created_at: product.createdAt
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
 * GET /api/products/export-csv
 * Export all active products as a CSV file
 * MUST be defined before /:id to avoid route conflict
 */
router.get('/export-csv', authenticateToken, async (req, res) => {
  try {
    const products = await db.Product.findAll({
      where: { merchant_id: req.merchantId, is_active: true },
      order: [['name', 'ASC']],
      include: [{
        model: db.Category,
        as: 'category',
        attributes: ['name'],
        required: false,
      }],
    });

    const headers = ['name', 'barcode', 'current_stock', 'reorder_threshold', 'unit', 'price', 'category'];

    const escapeCell = (val) => {
      const str = val == null ? '' : String(val);
      if (str.includes(',') || str.includes('"') || str.includes('\n')) {
        return `"${str.replace(/"/g, '""')}"`;
      }
      return str;
    };

    const rows = products.map(p => [
      escapeCell(p.name),
      escapeCell(p.barcode),
      escapeCell(p.current_stock),
      escapeCell(p.reorder_threshold),
      escapeCell(p.unit),
      escapeCell(p.price),
      escapeCell(p.category?.name),
    ].join(','));

    const csv = [headers.join(','), ...rows].join('\n');

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="products.csv"');
    res.send(csv);
  } catch (error) {
    console.error('Error exporting CSV:', error);
    res.status(500).json({ success: false, message: 'Failed to export products' });
  }
});

/**
 * GET /api/products/csv-template
 * Download blank CSV template for import
 */
router.get('/csv-template', authenticateToken, (req, res) => {
  const headers = 'name,barcode,current_stock,reorder_threshold,unit,price,category';
  const exampleRow = 'Example Product,1234567890,100,10,piece,9.99,Beverages';
  const csv = [headers, exampleRow].join('\n');

  res.setHeader('Content-Type', 'text/csv');
  res.setHeader('Content-Disposition', 'attachment; filename="products_template.csv"');
  res.send(csv);
});

/**
 * POST /api/products/import-csv
 * Import products from a CSV file (body: { csv_data: string })
 */
router.post('/import-csv', authenticateToken, checkSubscription, async (req, res) => {
  try {
    const { csv_data } = req.body;
    if (!csv_data || typeof csv_data !== 'string') {
      return res.status(400).json({ success: false, message: 'csv_data field is required' });
    }

    const lines = csv_data.trim().split('\n').filter(l => l.trim());
    if (lines.length < 2) {
      return res.status(400).json({ success: false, message: 'CSV must have a header row and at least one data row' });
    }

    const parseRow = (line) => {
      const result = [];
      let inQuotes = false;
      let cell = '';
      for (let i = 0; i < line.length; i++) {
        const ch = line[i];
        if (ch === '"') {
          if (inQuotes && line[i + 1] === '"') { cell += '"'; i++; }
          else { inQuotes = !inQuotes; }
        } else if (ch === ',' && !inQuotes) {
          result.push(cell.trim());
          cell = '';
        } else {
          cell += ch;
        }
      }
      result.push(cell.trim());
      return result;
    };

    const headerRow = parseRow(lines[0].toLowerCase());
    const col = (name) => headerRow.indexOf(name);

    const validUnits = ['piece', 'kg', 'liter', 'box', 'carton', 'bottle'];
    const results = { created: 0, skipped: 0, errors: [] };

    for (let i = 1; i < lines.length; i++) {
      const cells = parseRow(lines[i]);
      const name = cells[col('name')]?.trim();
      if (!name || name.length < 2) {
        results.errors.push({ row: i + 1, error: 'Name is required (min 2 characters)' });
        results.skipped++;
        continue;
      }

      const unit = cells[col('unit')]?.trim() || 'piece';
      if (!validUnits.includes(unit)) {
        results.errors.push({ row: i + 1, error: `Invalid unit "${unit}". Valid: ${validUnits.join(', ')}` });
        results.skipped++;
        continue;
      }

      const currentStock = parseInt(cells[col('current_stock')]) || 0;
      const reorderThreshold = parseInt(cells[col('reorder_threshold')]) || 5;
      const barcode = cells[col('barcode')]?.trim() || null;
      const priceRaw = cells[col('price')]?.trim();
      const price = priceRaw ? parseFloat(priceRaw) : null;
      const categoryName = cells[col('category')]?.trim() || null;

      const existing = await db.Product.findOne({
        where: { merchant_id: req.merchantId, name, is_active: true }
      });
      if (existing) {
        results.errors.push({ row: i + 1, error: `Product "${name}" already exists` });
        results.skipped++;
        continue;
      }

      let categoryId = null;
      if (categoryName) {
        const cat = await db.Category.findOne({
          where: { merchant_id: req.merchantId, name: categoryName, is_active: true }
        });
        if (cat) categoryId = cat.id;
      }

      await db.Product.create({
        merchant_id: req.merchantId,
        name,
        current_stock: currentStock,
        reorder_threshold: reorderThreshold,
        unit,
        barcode: barcode && barcode.length >= 8 ? barcode : null,
        price: price && !isNaN(price) ? price : null,
        category_id: categoryId,
      });

      results.created++;
    }

    res.json({
      success: true,
      message: `Import complete: ${results.created} products created, ${results.skipped} skipped`,
      data: results,
    });
  } catch (error) {
    console.error('Error importing CSV:', error);
    res.status(500).json({ success: false, message: 'Failed to import products' });
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
      },
      include: [
        {
          model: db.ProductImage,
          as: 'images',
          attributes: ['id', 'url', 'sort_order'],
          order: [['sort_order', 'ASC']]
        },
        {
          model: db.Category,
          as: 'category',
          attributes: ['id', 'name', 'color', 'icon'],
          required: false,
        }
      ]
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const p = product.toJSON();
    res.json({
      success: true,
      data: {
        product: {
          ...p,
          created_at: product.createdAt,
          updated_at: product.updatedAt,
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

    const { name, current_stock, reorder_threshold, unit, barcode, price, cost_price, category_id } = req.body;

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
    if (cost_price !== undefined) updateData.cost_price = cost_price != null ? cost_price : null;

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

    // Log the stock transaction for audit history
    await logStockTransaction({
      productId: product.id,
      merchantId: req.merchantId,
      type: 'manual_adjustment',
      oldQty: oldStock,
      newQty: newStock,
      reason: reason || null,
    }).catch(err => console.error('Failed to log stock transaction:', err));

    console.log(`📊 Stock adjusted: ${product.name} ${oldStock} → ${newStock} (${adjustment > 0 ? '+' : ''}${adjustment})`);

    // Fire low-stock notification if stock crossed below threshold (non-blocking)
    if (newStock <= product.reorder_threshold && oldStock > product.reorder_threshold) {
      const merchant = await db.Merchant.findByPk(req.merchantId, { attributes: ['fcm_token'] });
      if (merchant?.fcm_token) {
        notifyLowStock({
          fcmToken: merchant.fcm_token,
          productName: product.name,
          currentStock: newStock,
          unit: product.unit || 'unité',
          productId: product.id,
        }).catch(err => console.error('Failed to send low-stock notification:', err));
      }
    }

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

/**
 * GET /api/products/:id/stock-history
 * Paginated stock transaction history for a product
 */
router.get('/:id/stock-history', authenticateToken, async (req, res) => {
  try {
    const product = await db.Product.findOne({
      where: { id: req.params.id, merchant_id: req.merchantId, is_active: true }
    });
    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = Math.min(parseInt(req.query.limit) || 20, 100);
    const offset = (page - 1) * limit;
    const where = { product_id: product.id };
    if (req.query.type) where.type = req.query.type;

    const { count, rows } = await db.StockTransaction.findAndCountAll({
      where,
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: {
        transactions: rows.map(t => t.toJSON()),
        pagination: {
          current_page: page,
          total_pages: totalPages,
          total_items: count,
          per_page: limit,
          has_next_page: page < totalPages,
          has_prev_page: page > 1,
        }
      }
    });
  } catch (error) {
    console.error('Error fetching stock history:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch stock history' });
  }
});

// Product image routes
const { uploadProductImages } = require('../middleware/upload');
const fs = require('fs');
const path = require('path');

// POST /:id/images — upload up to 5 images
router.post('/:id/images', authenticateToken, uploadProductImages.array('images', 5), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, message: 'No image files provided' });
    }

    const product = await db.Product.findOne({
      where: { id: req.params.id, merchant_id: req.merchantId, is_active: true },
      include: [{ model: db.ProductImage, as: 'images' }]
    });

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const currentCount = product.images.length;
    const remaining = 5 - currentCount;

    if (req.files.length > remaining) {
      return res.status(400).json({
        success: false,
        message: `Maximum 5 images per product. You can add ${remaining} more.`
      });
    }

    let created;
    try {
      created = await Promise.all(req.files.map((file, i) =>
        db.ProductImage.create({
          product_id: product.id,
          url: file.location, // S3 absolute URL
          sort_order: currentCount + i
        })
      ));
    } catch (dbError) {
      throw dbError;
    }

    res.json({
      success: true,
      data: {
        images: created.map(img => ({ id: img.id, url: img.url, sort_order: img.sort_order }))
      }
    });
  } catch (error) {
    console.error('Error uploading product images:', error);
    res.status(500).json({ success: false, message: 'Failed to upload images' });
  }
});

// DELETE /:id/images/:imageId — delete a single product image
router.delete('/:id/images/:imageId', authenticateToken, async (req, res) => {
  try {
    const product = await db.Product.findOne({
      where: { id: req.params.id, merchant_id: req.merchantId, is_active: true }
    });

    if (!product) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    const image = await db.ProductImage.findOne({
      where: { id: req.params.imageId, product_id: product.id }
    });

    if (!image) {
      return res.status(404).json({ success: false, message: 'Image not found' });
    }

    // Delete file from disk
    const filepath = path.join(__dirname, '..', image.url);
    if (fs.existsSync(filepath)) fs.unlinkSync(filepath);

    await image.destroy();

    res.json({ success: true, message: 'Image deleted' });
  } catch (error) {
    console.error('Error deleting product image:', error);
    res.status(500).json({ success: false, message: 'Failed to delete image' });
  }
});

module.exports = router;
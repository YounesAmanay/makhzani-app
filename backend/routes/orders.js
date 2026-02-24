// backend/routes/orders.js
const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');
const { generateOrderPDF } = require('../utils/pdfGenerator');
const { logStockTransaction } = require('../utils/stockLogger');
const { notifyLowStock } = require('../utils/notificationService');

// Validation middleware
const validateOrder = [
  body('supplier_id')
    .notEmpty()
    .isUUID()
    .withMessage('Valid supplier ID is required'),
  body('items')
    .isArray({ min: 1 })
    .withMessage('At least one item is required'),
  body('items.*.product_id')
    .notEmpty()
    .isUUID()
    .withMessage('Valid product ID is required for each item'),
  body('items.*.quantity')
    .isFloat({ min: 0.001 })
    .withMessage('Quantity must be greater than 0'),
  body('items.*.unit_price')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Unit price must be positive'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes cannot exceed 500 characters')
];

const validateQuery = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  query('supplier_id')
    .optional()
    .isUUID()
    .withMessage('Supplier ID must be valid UUID'),
  query('status')
    .optional()
    .isIn(['draft', 'sent', 'all'])
    .withMessage('Status must be draft, sent, or all'),
  query('search')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Search query too long')
    .trim()
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
 * GET /api/orders
 * Get merchant's purchase orders with filtering and pagination
 */
router.get('/', authenticateToken, validateQuery, handleValidationErrors, async (req, res) => {
  try {
    const { page = 1, limit = 20, supplier_id, status = 'all', search } = req.query;
    const offset = (page - 1) * limit;

    // Build where conditions
    const whereConditions = {
      merchant_id: req.merchantId,
      is_active: true
    };

    if (supplier_id) {
      whereConditions.supplier_id = supplier_id;
    }

    if (status === 'draft') {
      whereConditions.pdf_generated_at = null;
    } else if (status === 'sent') {
      whereConditions.pdf_generated_at = { [db.Sequelize.Op.not]: null };
    }

    // Search: match order_number OR supplier name/business_name
    // Use two-query approach to avoid complex JOIN OR issues
    if (search && search.trim()) {
      const term = search.trim();

      // Find supplier IDs matching the search term
      const matchingSuppliers = await db.Supplier.findAll({
        attributes: ['id'],
        where: {
          [db.Sequelize.Op.or]: [
            { name: { [db.Sequelize.Op.like]: `%${term}%` } },
            { business_name: { [db.Sequelize.Op.like]: `%${term}%` } }
          ]
        }
      });
      const matchingSupplierIds = matchingSuppliers.map(s => s.id);

      // Filter: order_number matches OR supplier_id is in matching suppliers
      const orClauses = [
        { order_number: { [db.Sequelize.Op.like]: `%${term}%` } }
      ];
      if (matchingSupplierIds.length > 0) {
        orClauses.push({ supplier_id: { [db.Sequelize.Op.in]: matchingSupplierIds } });
      }
      whereConditions[db.Sequelize.Op.or] = orClauses;
    }

    const { count, rows: orders } = await db.PurchaseOrder.findAndCountAll({
      where: whereConditions,
      include: [
        {
          model: db.Supplier,
          as: 'supplier',
          attributes: ['id', 'name', 'business_name', 'phone_number']
        },
        {
          model: db.PurchaseOrderItem,
          as: 'items',
          include: [
            {
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'unit']
            }
          ]
        }
      ],
      order: [['created_at', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    // Calculate pagination info
    const totalPages = Math.ceil(count / limit);

    res.json({
      success: true,
      data: {
        orders: orders.map(order => ({
          id: order.id,
          order_number: order.order_number,
          supplier: {
            id: order.supplier.id,
            name: order.supplier.name,
            business_name: order.supplier.business_name,
            phone_number: order.supplier.phone_number
          },
          total_items: order.items.length,
          total_quantity: order.items.reduce((sum, item) => sum + parseFloat(item.quantity), 0),
          total_value: order.items.reduce((sum, item) => {
            return sum + (parseFloat(item.total_price || 0));
          }, 0),
          notes: order.notes,
          status: {
            pdf_generated: !!order.pdf_generated_at,
            sent: !!order.sent_at,
            sent_via: order.sent_via,
            received: !!order.received_at
          },
          pdf_url: order.pdf_url,
          created_at: order.created_at,
          pdf_generated_at: order.pdf_generated_at,
          sent_at: order.sent_at,
          received_at: order.received_at
        })),
        pagination: {
          current_page: parseInt(page),
          total_pages: totalPages,
          total_orders: count,
          has_next_page: parseInt(page) < totalPages,
          has_prev_page: parseInt(page) > 1,
          per_page: parseInt(limit),
          search: search && search.trim() ? search.trim() : null,
          supplier_id: supplier_id || null,
          status
        }
      }
    });

  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch orders',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/orders
 * Create a new purchase order
 */
router.post('/', authenticateToken, checkSubscription, validateOrder, handleValidationErrors, async (req, res) => {
  const transaction = await db.sequelize.transaction();

  try {
    const { supplier_id, items, notes } = req.body;

    // Verify supplier belongs to this merchant
    const supplierRelation = await db.Supplier.findOne({
      where: {
        id: supplier_id,
        merchant_id: req.merchantId,
        is_active: true
      },
      transaction
    });

    if (!supplierRelation) {
      await transaction.rollback();
      return res.status(404).json({
        success: false,
        message: 'Supplier not found or not linked to your account'
      });
    }

    // Verify all products exist and belong to merchant
    const productIds = items.map(item => item.product_id);
    const products = await db.Product.findAll({
      where: {
        id: productIds,
        merchant_id: req.merchantId,
        is_active: true
      },
      transaction
    });

    if (products.length !== productIds.length) {
      await transaction.rollback();
      return res.status(400).json({
        success: false,
        message: 'One or more products not found or not accessible'
      });
    }

    // Create purchase order (order_number will be auto-generated by hook)
    const order = await db.PurchaseOrder.create({
      merchant_id: req.merchantId,
      supplier_id: supplier_id,
      notes: notes,
      is_active: true
    }, { transaction });

    // Create order items with product snapshots
    const orderItems = [];
    for (const item of items) {
      const product = products.find(p => p.id === item.product_id);

      const orderItem = await db.PurchaseOrderItem.create({
        purchase_order_id: order.id,
        product_id: item.product_id,
        quantity: item.quantity,
        unit_price: item.unit_price || product.purchase_price || 0,
        total_price: (item.unit_price || product.purchase_price || 0) * item.quantity
      }, { transaction });

      orderItems.push(orderItem);
    }

    // Update supplier stats
    await db.Supplier.increment('total_orders', {
      where: { id: supplier_id },
      transaction,
    });
    await db.Supplier.update(
      { last_order_date: new Date() },
      { where: { id: supplier_id }, transaction }
    );

    await transaction.commit();

    // Fetch complete order with associations
    const completeOrder = await db.PurchaseOrder.findByPk(order.id, {
      include: [
        {
          model: db.Supplier,
          as: 'supplier',
          attributes: ['id', 'name', 'business_name', 'phone_number']
        },
        {
          model: db.PurchaseOrderItem,
          as: 'items',
          include: [
            {
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'unit']
            }
          ]
        }
      ]
    });

    res.status(201).json({
      success: true,
      message: 'Purchase order created successfully',
      data: {
        order: {
          id: completeOrder.id,
          order_number: completeOrder.order_number,
          supplier: completeOrder.supplier,
          items: completeOrder.items.map(item => ({
            id: item.id,
            product: item.product,
            product_name_snapshot: item.product_name_snapshot,
            quantity: parseFloat(item.quantity),
            unit_price: parseFloat(item.unit_price),
            total_price: parseFloat(item.total_price)
          })),
          total_value: completeOrder.items.reduce((sum, item) => sum + parseFloat(item.total_price), 0),
          notes: completeOrder.notes,
          created_at: completeOrder.created_at
        }
      }
    });

  } catch (error) {
    await transaction.rollback();
    console.error('Error creating order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create order',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * GET /api/orders/suggestions
 * Returns low-stock products grouped by the supplier they were last ordered from.
 */
router.get('/suggestions', authenticateToken, checkSubscription, async (req, res) => {
  try {
    // 1. Get all low-stock active products for this merchant
    const lowStockProducts = await db.Product.findAll({
      where: {
        merchant_id: req.merchantId,
        is_active: true,
        current_stock: { [db.Sequelize.Op.lte]: db.Sequelize.col('reorder_threshold') },
      },
      attributes: ['id', 'name', 'current_stock', 'reorder_threshold', 'unit'],
    });

    if (lowStockProducts.length === 0) {
      return res.json({ success: true, data: { suggestions: [], unassigned: [] } });
    }

    const productIds = lowStockProducts.map(p => p.id);

    // 2. For each low-stock product, find the most recent order that included it
    const lastOrderRows = await db.sequelize.query(`
      SELECT
        poi.product_id,
        po.supplier_id,
        poi.unit_price AS last_order_price,
        po.created_at AS last_order_date
      FROM purchase_order_items poi
      INNER JOIN purchase_orders po ON poi.purchase_order_id = po.id
      INNER JOIN (
        SELECT poi2.product_id, MAX(po2.created_at) AS max_date
        FROM purchase_order_items poi2
        INNER JOIN purchase_orders po2 ON poi2.purchase_order_id = po2.id
        WHERE po2.merchant_id = :merchantId
          AND poi2.product_id IN (:productIds)
        GROUP BY poi2.product_id
      ) latest ON poi.product_id = latest.product_id AND po.created_at = latest.max_date
      WHERE po.merchant_id = :merchantId
    `, {
      replacements: { merchantId: req.merchantId, productIds },
      type: db.Sequelize.QueryTypes.SELECT,
    });

    // 3. Build map: productId → { supplierId, lastOrderPrice }
    const productSupplierMap = {};
    for (const row of lastOrderRows) {
      productSupplierMap[row.product_id] = {
        supplierId: row.supplier_id,
        lastOrderPrice: parseFloat(row.last_order_price) || null,
      };
    }

    // 4. Fetch supplier details for all referenced suppliers
    const supplierIds = [...new Set(Object.values(productSupplierMap).map(v => v.supplierId))];
    const suppliers = supplierIds.length > 0
      ? await db.Supplier.findAll({
          where: { id: supplierIds },
          attributes: ['id', 'name', 'business_name', 'phone_number'],
        })
      : [];
    const supplierMap = Object.fromEntries(suppliers.map(s => [s.id, s.toJSON()]));

    // 5. Group products by supplier
    const grouped = {};
    const unassigned = [];

    for (const product of lowStockProducts) {
      const entry = productSupplierMap[product.id];
      const productData = {
        id: product.id,
        name: product.name,
        current_stock: product.current_stock,
        reorder_threshold: product.reorder_threshold,
        unit: product.unit,
        shortage: product.reorder_threshold - product.current_stock,
        last_order_price: entry?.lastOrderPrice ?? null,
      };

      if (entry?.supplierId && supplierMap[entry.supplierId]) {
        if (!grouped[entry.supplierId]) grouped[entry.supplierId] = [];
        grouped[entry.supplierId].push(productData);
      } else {
        unassigned.push(productData);
      }
    }

    const suggestions = Object.entries(grouped).map(([supplierId, products]) => ({
      supplier: supplierMap[supplierId],
      products,
    }));

    return res.json({ success: true, data: { suggestions, unassigned } });
  } catch (err) {
    console.error('[Suggestions]', err);
    return res.status(500).json({ success: false, message: 'Server error' });
  }
});

/**
 * GET /api/orders/:id
 * Get specific order details
 */
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const order = await db.PurchaseOrder.findOne({
      where: {
        id: id,
        merchant_id: req.merchantId,
        is_active: true
      },
      include: [
        {
          model: db.Supplier,
          as: 'supplier',
          attributes: ['id', 'name', 'business_name', 'phone_number', 'email', 'address']
        },
        {
          model: db.PurchaseOrderItem,
          as: 'items',
          include: [
            {
              model: db.Product,
              as: 'product',
              attributes: ['id', 'name', 'unit', 'current_stock']
            }
          ]
        }
      ]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    const totalValue = order.items.reduce((sum, item) => sum + parseFloat(item.total_price), 0);
    const totalQuantity = order.items.reduce((sum, item) => sum + parseFloat(item.quantity), 0);

    res.json({
      success: true,
      data: {
        order: {
          id: order.id,
          order_number: order.order_number,
          supplier: order.supplier,
          items: order.items.map(item => ({
            id: item.id,
            product: item.product,
            product_name_snapshot: item.product_name_snapshot,
            quantity: parseFloat(item.quantity),
            unit_price: parseFloat(item.unit_price),
            total_price: parseFloat(item.total_price)
          })),
          summary: {
            total_items: order.items.length,
            total_quantity: totalQuantity,
            total_value: totalValue
          },
          notes: order.notes,
          pdf_url: order.pdf_url,
          status: {
            pdf_generated: !!order.pdf_generated_at,
            sent: !!order.sent_at,
            sent_via: order.sent_via,
            received: !!order.received_at
          },
          timestamps: {
            created_at: order.created_at,
            updated_at: order.updated_at,
            pdf_generated_at: order.pdf_generated_at,
            sent_at: order.sent_at,
            received_at: order.received_at
          }
        }
      }
    });

  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch order',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/orders/:id/generate-pdf
 * Generate actual PDF file for order
 */
router.post('/:id/generate-pdf', authenticateToken, checkSubscription, async (req, res) => {
  try {
    const { id } = req.params;

    // Fetch order with all relations
    const order = await db.PurchaseOrder.findOne({
      where: {
        id: id,
        merchant_id: req.merchantId,
        is_active: true
      },
      include: [
        {
          model: db.Merchant,
          as: 'merchant',
          attributes: ['id', 'name', 'shop_name', 'phone_number', 'region']
        },
        {
          model: db.Supplier,
          as: 'supplier',
          attributes: ['id', 'name', 'business_name', 'phone_number', 'email', 'address']
        },
        {
          model: db.PurchaseOrderItem,
          as: 'items',
          include: [{
            model: db.Product,
            as: 'product',
            attributes: ['id', 'name', 'unit']
          }]
        }
      ]
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Generate PDF file
    const pdfData = await generateOrderPDF(order);

    // Update order with PDF info
    await order.update({
      pdf_generated_at: new Date(),
      pdf_url: pdfData.url
    });

    res.json({
      success: true,
      message: 'PDF generated successfully',
      data: {
        order_id: order.id,
        order_number: order.order_number,
        pdf_generated_at: order.pdf_generated_at,
        pdf_url: pdfData.url,
        pdf_filename: pdfData.filename
      }
    });

  } catch (error) {
    console.error('Error generating PDF:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate PDF',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/orders/:id/mark-sent
 * Mark order as sent via specified method
 */
router.post('/:id/mark-sent', authenticateToken, [
  body('sent_via')
    .isIn(['whatsapp', 'email', 'phone', 'in_person'])
    .withMessage('sent_via must be whatsapp, email, phone, or in_person')
], handleValidationErrors, async (req, res) => {
  try {
    const { id } = req.params;
    const { sent_via } = req.body;

    const order = await db.PurchaseOrder.findOne({
      where: {
        id: id,
        merchant_id: req.merchantId,
        is_active: true
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    // Update order with sent information
    await order.update({
      sent_at: new Date(),
      sent_via: sent_via,
      // Also mark PDF as generated if not already
      pdf_generated_at: order.pdf_generated_at || new Date()
    });

    res.json({
      success: true,
      message: `Order marked as sent via ${sent_via}`,
      data: {
        order_id: order.id,
        order_number: order.order_number,
        sent_at: order.sent_at,
        sent_via: order.sent_via,
        pdf_generated_at: order.pdf_generated_at
      }
    });

  } catch (error) {
    console.error('Error marking order as sent:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark order as sent',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * GET /api/orders/:id/download-pdf
 * Download order PDF file
 */
router.get('/:id/download-pdf', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Verify order exists and belongs to user
    const order = await db.PurchaseOrder.findOne({
      where: {
        id: id,
        merchant_id: req.merchantId,
        is_active: true
      }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    if (!order.pdf_url) {
      return res.status(400).json({
        success: false,
        message: 'PDF has not been generated for this order'
      });
    }

    // PDF is stored on S3 — redirect to the absolute S3 URL
    res.redirect(order.pdf_url);

  } catch (error) {
    console.error('Error downloading PDF:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to download PDF',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/orders/:id/receive
 * Mark order as received and auto-update stock for all items.
 * Idempotent: re-receiving an already-received order is rejected.
 */
router.post('/:id/receive', authenticateToken, checkSubscription, async (req, res) => {
  const transaction = await db.sequelize.transaction();

  try {
    const { id } = req.params;

    const order = await db.PurchaseOrder.findOne({
      where: { id, merchant_id: req.merchantId, is_active: true },
      include: [
        {
          model: db.PurchaseOrderItem,
          as: 'items',
          include: [{ model: db.Product, as: 'product' }]
        }
      ],
      transaction
    });

    if (!order) {
      await transaction.rollback();
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    if (order.received_at) {
      await transaction.rollback();
      return res.status(409).json({
        success: false,
        message: 'Order has already been received'
      });
    }

    // Update stock for each item and log the transaction
    for (const item of order.items) {
      const product = item.product;
      if (!product) continue;

      const oldStock = parseFloat(product.current_stock) || 0;
      const received = parseFloat(item.quantity) || 0;
      const newStock = oldStock + received;

      await product.update({ current_stock: newStock }, { transaction });

      await logStockTransaction({
        productId: product.id,
        merchantId: req.merchantId,
        type: 'order_received',
        oldQty: oldStock,
        newQty: newStock,
        reason: `Received from order ${order.order_number}`,
        referenceId: order.id,
        referenceType: 'purchase_order',
        transaction,
      });
    }

    // Mark order as received
    await order.update({ received_at: new Date() }, { transaction });

    await transaction.commit();

    // After commit: check for any items that are still below threshold and notify (non-blocking)
    const merchant = await db.Merchant.findByPk(req.merchantId, { attributes: ['fcm_token'] });
    if (merchant?.fcm_token) {
      for (const item of order.items) {
        const product = item.product;
        if (!product) continue;
        const newStock = (parseFloat(product.current_stock) || 0) + (parseFloat(item.quantity) || 0);
        if (newStock <= product.reorder_threshold) {
          notifyLowStock({
            fcmToken: merchant.fcm_token,
            productName: product.name,
            currentStock: newStock,
            unit: product.unit || 'unité',
            productId: product.id,
          }).catch(err => console.error('Failed to send low-stock notification:', err));
        }
      }
    }

    res.json({
      success: true,
      message: 'Order received and stock updated successfully',
      data: {
        order_id: order.id,
        order_number: order.order_number,
        received_at: order.received_at,
        items_updated: order.items.length
      }
    });

  } catch (error) {
    await transaction.rollback();
    console.error('Error receiving order:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to receive order',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
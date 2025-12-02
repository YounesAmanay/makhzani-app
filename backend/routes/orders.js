// backend/routes/orders.js
const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');
const { generateOrderPDF } = require('../utils/pdfGenerator');
const fs = require('fs');
const path = require('path');

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
    .withMessage('Status must be draft, sent, or all')
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
    const { page = 1, limit = 20, supplier_id, status = 'all' } = req.query;
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
            sent_via: order.sent_via
          },
          pdf_url: order.pdf_url,
          created_at: order.created_at,
          pdf_generated_at: order.pdf_generated_at,
          sent_at: order.sent_at
        })),
        pagination: {
          current_page: parseInt(page),
          total_pages: totalPages,
          total_orders: count,
          has_next_page: page < totalPages,
          has_prev_page: page > 1,
          per_page: parseInt(limit)
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

    // Verify supplier relationship exists
    const supplierRelation = await db.MerchantSupplier.findOne({
      where: {
        merchant_id: req.merchantId,
        supplier_id: supplier_id,
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
            sent_via: order.sent_via
          },
          timestamps: {
            created_at: order.created_at,
            updated_at: order.updated_at,
            pdf_generated_at: order.pdf_generated_at,
            sent_at: order.sent_at
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

    // Construct file path
    const filename = path.basename(order.pdf_url);
    const filepath = path.join(__dirname, '../uploads/pdfs', filename);

    // Check if file exists
    if (!fs.existsSync(filepath)) {
      return res.status(404).json({
        success: false,
        message: 'PDF file not found'
      });
    }

    // Send file
    res.download(filepath, `order-${order.order_number}.pdf`);

  } catch (error) {
    console.error('Error downloading PDF:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to download PDF',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
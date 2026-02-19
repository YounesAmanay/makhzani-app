// backend/routes/suppliers.js
const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');

// Validation middleware
const validateSupplier = [
  body('name')
    .notEmpty()
    .isLength({ min: 2, max: 100 })
    .withMessage('Supplier name must be 2-100 characters'),
  body('phone_number')
    .matches(/^\+212[5-7]\d{8}$/)
    .withMessage('Invalid Morocco phone number. Use +212XXXXXXXXX format'),
  body('business_name')
    .optional()
    .isLength({ min: 2, max: 100 })
    .withMessage('Business name must be 2-100 characters'),
  body('email')
    .optional()
    .isEmail()
    .withMessage('Invalid email format'),
  body('address')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Address too long'),
  body('city')
    .optional()
    .isIn(['Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other'])
    .withMessage('Invalid city')
];

const validateSupplierRelation = [
  body('preferred_contact_method')
    .optional()
    .isIn(['whatsapp', 'phone', 'email'])
    .withMessage('Invalid contact method'),
  body('payment_terms')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Payment terms too long'),
  body('merchant_notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes too long')
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

const validateSuppliersQuery = [
  query('search')
    .optional()
    .isLength({ max: 100 })
    .withMessage('Search query too long')
    .trim(),
  query('city')
    .optional()
    .isIn(['Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other'])
    .withMessage('Invalid city')
];

/**
 * GET /api/suppliers
 * Get merchant's suppliers with relationship details, optional search and city filter
 */
router.get('/', authenticateToken, validateSuppliersQuery, handleValidationErrors, async (req, res) => {
  try {
    const { search, city } = req.query;

    // Build supplier where clause
    const supplierWhere = { is_active: true };

    if (city) {
      supplierWhere.city = city;
    }

    if (search && search.trim()) {
      supplierWhere[db.Sequelize.Op.or] = [
        { name: { [db.Sequelize.Op.like]: `%${search.trim()}%` } },
        { business_name: { [db.Sequelize.Op.like]: `%${search.trim()}%` } },
        { phone_number: { [db.Sequelize.Op.like]: `%${search.trim()}%` } }
      ];
    }

    const suppliers = await db.Supplier.findAll({
      include: [
        {
          model: db.MerchantSupplier,
          as: 'MerchantSuppliers',
          where: {
            merchant_id: req.merchantId,
            is_active: true
          },
          attributes: [
            'preferred_contact_method',
            'payment_terms',
            'merchant_notes',
            'last_order_date',
            'total_orders',
            'created_at'
          ]
        }
      ],
      where: supplierWhere
    });

    res.json({
      success: true,
      data: {
        suppliers: suppliers.map(supplier => ({
          id: supplier.id,
          name: supplier.name,
          business_name: supplier.business_name,
          phone_number: supplier.phone_number,
          email: supplier.email,
          address: supplier.address,
          city: supplier.city,
          supplier_type: supplier.supplier_type,
          relationship: {
            preferred_contact_method: supplier.MerchantSuppliers[0]?.preferred_contact_method,
            payment_terms: supplier.MerchantSuppliers[0]?.payment_terms,
            merchant_notes: supplier.MerchantSuppliers[0]?.merchant_notes,
            last_order_date: supplier.MerchantSuppliers[0]?.last_order_date,
            total_orders: supplier.MerchantSuppliers[0]?.total_orders || 0,
            linked_since: supplier.MerchantSuppliers[0]?.created_at
          }
        })),
        meta: {
          total: suppliers.length,
          search: search && search.trim() ? search.trim() : null,
          city: city || null
        }
      }
    });

  } catch (error) {
    console.error('Error fetching suppliers:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch suppliers',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * POST /api/suppliers
 * Add/Link supplier to merchant
 */
router.post('/', authenticateToken, checkSubscription, [...validateSupplier, ...validateSupplierRelation], handleValidationErrors, async (req, res) => {
  const transaction = await db.sequelize.transaction();
  
  try {
    const { 
      name, 
      phone_number, 
      business_name, 
      email, 
      address, 
      city,
      preferred_contact_method = 'whatsapp',
      payment_terms,
      merchant_notes
    } = req.body;

    // Check if merchant already has this supplier
    const existingRelation = await db.MerchantSupplier.findOne({
      include: [
        {
          model: db.Supplier,
          as: 'supplier',
          where: { phone_number: phone_number.trim() }
        }
      ],
      where: { 
        merchant_id: req.merchantId,
        is_active: true 
      },
      transaction
    });

    if (existingRelation) {
      await transaction.rollback();
      return res.status(400).json({
        success: false,
        message: 'You already have a supplier with this phone number',
        code: 'SUPPLIER_ALREADY_LINKED'
      });
    }

    // Try to find existing supplier by phone number
    let supplier = await db.Supplier.findOne({
      where: { phone_number: phone_number.trim() },
      transaction
    });

    let isNewSupplier = false;

    if (!supplier) {
      // Create new supplier
      supplier = await db.Supplier.create({
        name: name.trim(),
        phone_number: phone_number.trim(),
        business_name: business_name?.trim() || null,
        email: email?.trim() || null,
        address: address?.trim() || null,
        city: city || null
      }, { transaction });
      
      isNewSupplier = true;
      console.log(`👤 Created new supplier: ${supplier.name} (${supplier.id})`);
    } else {
      // Update existing supplier if new information provided
      const updateData = {};
      if (business_name && !supplier.business_name) updateData.business_name = business_name.trim();
      if (email && !supplier.email) updateData.email = email.trim();
      if (address && !supplier.address) updateData.address = address.trim();
      if (city && !supplier.city) updateData.city = city;

      if (Object.keys(updateData).length > 0) {
        await supplier.update(updateData, { transaction });
        console.log(`📝 Updated existing supplier: ${supplier.name} (${supplier.id})`);
      }
    }

    // Create merchant-supplier relationship
    const relationship = await db.MerchantSupplier.create({
      merchant_id: req.merchantId,
      supplier_id: supplier.id,
      preferred_contact_method,
      payment_terms: payment_terms?.trim() || null,
      merchant_notes: merchant_notes?.trim() || null
    }, { transaction });

    await transaction.commit();

    console.log(`🤝 Linked supplier to merchant: ${supplier.name} → Merchant ${req.merchantId}`);

    res.status(201).json({
      success: true,
      message: isNewSupplier ? 'New supplier created and linked' : 'Existing supplier linked to your account',
      data: {
        supplier: {
          id: supplier.id,
          name: supplier.name,
          business_name: supplier.business_name,
          phone_number: supplier.phone_number,
          email: supplier.email,
          address: supplier.address,
          city: supplier.city,
          is_new_supplier: isNewSupplier
        },
        relationship: {
          preferred_contact_method: relationship.preferred_contact_method,
          payment_terms: relationship.payment_terms,
          merchant_notes: relationship.merchant_notes,
          created_at: relationship.created_at
        }
      }
    });

  } catch (error) {
    await transaction.rollback();
    console.error('Error adding supplier:', error);
    
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(400).json({
        success: false,
        message: 'A supplier with this phone number already exists',
        code: 'DUPLICATE_PHONE_NUMBER'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to add supplier',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * GET /api/suppliers/:id
 * Get specific supplier details
 */
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const supplier = await db.Supplier.findOne({
      where: { id: req.params.id, is_active: true },
      include: [
        {
          model: db.MerchantSupplier,
          as: 'MerchantSuppliers',
          where: { 
            merchant_id: req.merchantId,
            is_active: true 
          },
          required: true
        }
      ]
    });

    if (!supplier) {
      return res.status(404).json({
        success: false,
        message: 'Supplier not found or not linked to your account'
      });
    }

    // Get order history with this supplier
    const orders = await db.PurchaseOrder.findAll({
      where: {
        merchant_id: req.merchantId,
        supplier_id: supplier.id,
        is_active: true
      },
      order: [['created_at', 'DESC']],
      limit: 10,
      attributes: ['id', 'order_number', 'pdf_generated_at', 'sent_at', 'created_at']
    });

    res.json({
      success: true,
      data: {
        supplier: {
          id: supplier.id,
          name: supplier.name,
          business_name: supplier.business_name,
          phone_number: supplier.phone_number,
          email: supplier.email,
          address: supplier.address,
          city: supplier.city,
          supplier_type: supplier.supplier_type,
          relationship: {
            preferred_contact_method: supplier.MerchantSuppliers[0].preferred_contact_method,
            payment_terms: supplier.MerchantSuppliers[0].payment_terms,
            merchant_notes: supplier.MerchantSuppliers[0].merchant_notes,
            last_order_date: supplier.MerchantSuppliers[0].last_order_date,
            total_orders: supplier.MerchantSuppliers[0].total_orders,
            linked_since: supplier.MerchantSuppliers[0].created_at
          }
        },
        recent_orders: orders.map(order => ({
          id: order.id,
          order_number: order.order_number,
          created_at: order.created_at,
          pdf_generated: !!order.pdf_generated_at,
          sent: !!order.sent_at
        }))
      }
    });

  } catch (error) {
    console.error('Error fetching supplier:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch supplier',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * PUT /api/suppliers/:id
 * Update supplier relationship details
 */
router.put('/:id', authenticateToken, validateSupplierRelation, handleValidationErrors, async (req, res) => {
  try {
    const { preferred_contact_method, payment_terms, merchant_notes } = req.body;

    const relationship = await db.MerchantSupplier.findOne({
      where: {
        supplier_id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true
      },
      include: [{ model: db.Supplier, as: 'supplier' }]
    });

    if (!relationship) {
      return res.status(404).json({
        success: false,
        message: 'Supplier not found or not linked to your account'
      });
    }

    // Update relationship details
    const updateData = {};
    if (preferred_contact_method !== undefined) updateData.preferred_contact_method = preferred_contact_method;
    if (payment_terms !== undefined) updateData.payment_terms = payment_terms?.trim() || null;
    if (merchant_notes !== undefined) updateData.merchant_notes = merchant_notes?.trim() || null;

    await relationship.update(updateData);

    console.log(`📝 Updated supplier relationship: ${relationship.supplier.name}`);

    res.json({
      success: true,
      message: 'Supplier relationship updated successfully',
      data: {
        supplier_id: relationship.supplier.id,
        supplier_name: relationship.supplier.name,
        relationship: {
          preferred_contact_method: relationship.preferred_contact_method,
          payment_terms: relationship.payment_terms,
          merchant_notes: relationship.merchant_notes,
          updated_at: relationship.updated_at
        }
      }
    });

  } catch (error) {
    console.error('Error updating supplier relationship:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update supplier relationship',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

/**
 * DELETE /api/suppliers/:id
 * Remove supplier relationship (soft delete)
 */
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const relationship = await db.MerchantSupplier.findOne({
      where: {
        supplier_id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true
      },
      include: [{ model: db.Supplier, as: 'supplier' }]
    });

    if (!relationship) {
      return res.status(404).json({
        success: false,
        message: 'Supplier not found or not linked to your account'
      });
    }

    // Check if there are any orders with this supplier
    const orderCount = await db.PurchaseOrder.count({
      where: {
        merchant_id: req.merchantId,
        supplier_id: req.params.id,
        is_active: true
      }
    });

    if (orderCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Cannot remove supplier. You have ${orderCount} order(s) with this supplier.`,
        code: 'SUPPLIER_HAS_ORDERS',
        order_count: orderCount
      });
    }

    // Soft delete the relationship
    await relationship.update({ is_active: false });

    console.log(`🗑️ Removed supplier relationship: ${relationship.supplier.name}`);

    res.json({
      success: true,
      message: 'Supplier removed from your account successfully'
    });

  } catch (error) {
    console.error('Error removing supplier:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove supplier',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error'
    });
  }
});

module.exports = router;
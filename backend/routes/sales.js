const express = require('express');
const router = express.Router();
const { body, query, validationResult } = require('express-validator');
const { authenticateToken, checkSubscription } = require('../middleware/auth');
const db = require('../models');
const { logStockTransaction } = require('../utils/stockLogger');
const { notifyLowStock } = require('../utils/notificationService');
const { Op } = require('sequelize');

// ─── Validation ──────────────────────────────────────────────────────────────

const validateSale = [
  body('items')
    .isArray({ min: 1 })
    .withMessage('At least one item is required'),
  body('items.*.product_id')
    .notEmpty().isUUID()
    .withMessage('Valid product ID is required for each item'),
  body('items.*.quantity')
    .isFloat({ min: 0.001 })
    .withMessage('Quantity must be greater than 0'),
  body('items.*.unit_price')
    .isFloat({ min: 0.01 })
    .withMessage('Unit price must be greater than zero'),
  body('notes')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Notes cannot exceed 500 characters'),
];

const validateListQuery = [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 50 }),
  query('date_from').optional().isISO8601(),
  query('date_to').optional().isISO8601(),
];

const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, message: 'Validation failed', errors: errors.array() });
  }
  next();
};

// ─── GET /api/sales/summary ───────────────────────────────────────────────────

router.get('/summary', authenticateToken, async (req, res) => {
  try {
    const merchantId = req.merchantId;

    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const [todayResult, monthResult, totalResult] = await Promise.all([
      db.Sale.findAll({
        where: { merchant_id: merchantId, is_cancelled: false, created_at: { [Op.gte]: startOfToday } },
        attributes: [
          [db.Sequelize.fn('SUM', db.Sequelize.col('total_amount')), 'amount'],
          [db.Sequelize.fn('COUNT', db.Sequelize.col('id')), 'count'],
        ],
        raw: true,
      }),
      db.Sale.findAll({
        where: { merchant_id: merchantId, is_cancelled: false, created_at: { [Op.gte]: startOfMonth } },
        attributes: [
          [db.Sequelize.fn('SUM', db.Sequelize.col('total_amount')), 'amount'],
          [db.Sequelize.fn('COUNT', db.Sequelize.col('id')), 'count'],
        ],
        raw: true,
      }),
      db.Sale.findAll({
        where: { merchant_id: merchantId, is_cancelled: false },
        attributes: [
          [db.Sequelize.fn('SUM', db.Sequelize.col('total_amount')), 'amount'],
          [db.Sequelize.fn('COUNT', db.Sequelize.col('id')), 'count'],
        ],
        raw: true,
      }),
    ]);

    res.json({
      success: true,
      data: {
        today: {
          amount: parseFloat(todayResult[0]?.amount ?? 0),
          count: parseInt(todayResult[0]?.count ?? 0),
        },
        this_month: {
          amount: parseFloat(monthResult[0]?.amount ?? 0),
          count: parseInt(monthResult[0]?.count ?? 0),
        },
        total: {
          amount: parseFloat(totalResult[0]?.amount ?? 0),
          count: parseInt(totalResult[0]?.count ?? 0),
        },
      },
    });
  } catch (err) {
    console.error('Error fetching sales summary:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch sales summary' });
  }
});

// ─── GET /api/sales ───────────────────────────────────────────────────────────

router.get('/', authenticateToken, validateListQuery, handleValidation, async (req, res) => {
  try {
    const merchantId = req.merchantId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    const where = { merchant_id: merchantId, is_cancelled: false };

    if (req.query.date_from) {
      where.created_at = { ...where.created_at, [Op.gte]: new Date(req.query.date_from) };
    }
    if (req.query.date_to) {
      const to = new Date(req.query.date_to);
      to.setHours(23, 59, 59, 999);
      where.created_at = { ...where.created_at, [Op.lte]: to };
    }

    const { count, rows } = await db.Sale.findAndCountAll({
      where,
      include: [{
        model: db.SaleItem,
        as: 'items',
        attributes: ['id', 'product_id', 'quantity', 'unit_price', 'total_price', 'product_name_snapshot', 'product_unit_snapshot'],
      }],
      order: [['created_at', 'DESC']],
      limit,
      offset,
    });

    res.json({
      success: true,
      data: {
        sales: rows.map(s => ({
          id: s.id,
          sale_number: s.sale_number,
          total_items: s.total_items,
          total_amount: parseFloat(s.total_amount),
          notes: s.notes,
          is_cancelled: s.is_cancelled,
          items: (s.items || []).map(si => ({
            id: si.id,
            product_id: si.product_id,
            quantity: parseFloat(si.quantity),
            unit_price: parseFloat(si.unit_price),
            total_price: parseFloat(si.total_price),
            product_name_snapshot: si.product_name_snapshot,
            product_unit_snapshot: si.product_unit_snapshot,
          })),
          created_at: s.createdAt.toISOString(),
        })),
        pagination: { total: count, page, limit, total_pages: Math.ceil(count / limit) },
      },
    });
  } catch (err) {
    console.error('Error fetching sales:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch sales' });
  }
});

// ─── GET /api/sales/:id ───────────────────────────────────────────────────────

router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const sale = await db.Sale.findOne({
      where: { id: req.params.id, merchant_id: req.merchantId },
      include: [{
        model: db.SaleItem,
        as: 'items',
        attributes: ['id', 'product_id', 'quantity', 'unit_price', 'total_price', 'product_name_snapshot', 'product_unit_snapshot'],
      }],
    });

    if (!sale) return res.status(404).json({ success: false, message: 'Sale not found' });

    res.json({
      success: true,
      data: {
        id: sale.id,
        sale_number: sale.sale_number,
        total_items: sale.total_items,
        total_amount: parseFloat(sale.total_amount),
        notes: sale.notes,
        is_cancelled: sale.is_cancelled,
        items: (sale.items || []).map(si => ({
          id: si.id,
          product_id: si.product_id,
          quantity: parseFloat(si.quantity),
          unit_price: parseFloat(si.unit_price),
          total_price: parseFloat(si.total_price),
          product_name_snapshot: si.product_name_snapshot,
          product_unit_snapshot: si.product_unit_snapshot,
        })),
        created_at: sale.createdAt.toISOString(),
      },
    });
  } catch (err) {
    console.error('Error fetching sale:', err);
    res.status(500).json({ success: false, message: 'Failed to fetch sale' });
  }
});

// ─── POST /api/sales ──────────────────────────────────────────────────────────

router.post('/', authenticateToken, checkSubscription, validateSale, handleValidation, async (req, res) => {
  const transaction = await db.sequelize.transaction();
  try {
    const merchantId = req.merchantId;
    const { items, notes } = req.body;

    // Validate all products belong to this merchant and have sufficient stock
    const productIds = items.map(i => i.product_id);
    const products = await db.Product.findAll({
      where: { id: productIds, merchant_id: merchantId, is_active: true },
      transaction,
    });

    if (products.length !== productIds.length) {
      await transaction.rollback();
      return res.status(400).json({ success: false, message: 'One or more products not found' });
    }

    const productMap = Object.fromEntries(products.map(p => [p.id, p]));

    // Check stock sufficiency
    for (const item of items) {
      const product = productMap[item.product_id];
      if (product.current_stock < item.quantity) {
        await transaction.rollback();
        return res.status(400).json({
          success: false,
          message: `Insufficient stock for "${product.name}". Available: ${product.current_stock} ${product.unit}`,
          errors: [{ path: 'quantity', product_id: item.product_id, msg: 'Insufficient stock' }],
        });
      }
    }

    // Compute totals
    const totalAmount = items.reduce((sum, item) => sum + item.quantity * item.unit_price, 0);

    // Create Sale
    const sale = await db.Sale.create({
      merchant_id: merchantId,
      total_items: items.length,
      total_amount: totalAmount,
      notes: notes || null,
    }, { transaction });

    // Create SaleItems + decrement stock
    const saleItems = [];
    for (const item of items) {
      const product = productMap[item.product_id];
      const oldStock = product.current_stock;
      const newStock = oldStock - item.quantity;

      // Create sale item
      const saleItem = await db.SaleItem.create({
        sale_id: sale.id,
        product_id: item.product_id,
        quantity: item.quantity,
        unit_price: item.unit_price,
        total_price: item.quantity * item.unit_price,
        product_name_snapshot: product.name,
        product_unit_snapshot: product.unit,
      }, { transaction });
      saleItems.push(saleItem);

      // Decrement stock
      await product.update({ current_stock: newStock }, { transaction });

      // Log stock transaction
      await logStockTransaction({
        productId: product.id,
        merchantId,
        type: 'sale',
        oldQty: oldStock,
        newQty: newStock,
        reason: `Sold in sale ${sale.sale_number}`,
        referenceId: sale.id,
        referenceType: 'sale',
        transaction,
      });
    }

    await transaction.commit();

    // Non-blocking: fire low-stock notifications
    const merchant = await db.Merchant.findByPk(merchantId, { attributes: ['fcm_token'] });
    if (merchant?.fcm_token) {
      for (const item of items) {
        const product = productMap[item.product_id];
        const newStock = product.current_stock - item.quantity;
        const oldStock = product.current_stock;
        if (newStock <= product.reorder_threshold && oldStock > product.reorder_threshold) {
          notifyLowStock({
            fcmToken: merchant.fcm_token,
            productName: product.name,
            currentStock: newStock,
            unit: product.unit,
            productId: product.id,
          }).catch(err => console.error('Low-stock notify failed:', err));
        }
      }
    }

    // Return sale with items
    res.status(201).json({
      success: true,
      message: 'Sale recorded successfully',
      data: {
        id: sale.id,
        sale_number: sale.sale_number,
        total_items: sale.total_items,
        total_amount: parseFloat(sale.total_amount),
        notes: sale.notes,
        items: saleItems.map(si => ({
          id: si.id,
          product_id: si.product_id,
          quantity: parseFloat(si.quantity),
          unit_price: parseFloat(si.unit_price),
          total_price: parseFloat(si.total_price),
          product_name_snapshot: si.product_name_snapshot,
          product_unit_snapshot: si.product_unit_snapshot,
        })),
        created_at: sale.createdAt.toISOString(),
      },
    });
  } catch (err) {
    await transaction.rollback();
    console.error('Error creating sale:', err);
    res.status(500).json({ success: false, message: 'Failed to record sale' });
  }
});

// ─── DELETE /api/sales/:id ────────────────────────────────────────────────────
// Cancel a sale (within 24h) — restores stock

router.delete('/:id', authenticateToken, async (req, res) => {
  const transaction = await db.sequelize.transaction();
  try {
    const sale = await db.Sale.findOne({
      where: { id: req.params.id, merchant_id: req.merchantId, is_cancelled: false },
      include: [{ model: db.SaleItem, as: 'items' }],
      transaction,
    });

    if (!sale) {
      await transaction.rollback();
      return res.status(404).json({ success: false, message: 'Sale not found' });
    }

    // Only allow cancellation within 24 hours
    const ageHours = (Date.now() - sale.createdAt.getTime()) / 3_600_000;
    if (ageHours > 24) {
      await transaction.rollback();
      return res.status(400).json({ success: false, message: 'Sale can only be cancelled within 24 hours' });
    }

    // Restore stock for each item
    for (const item of sale.items) {
      const product = await db.Product.findByPk(item.product_id, { transaction });
      if (product) {
        const oldStock = product.current_stock;
        const newStock = oldStock + parseFloat(item.quantity);
        await product.update({ current_stock: newStock }, { transaction });
        await logStockTransaction({
          productId: product.id,
          merchantId: req.merchantId,
          type: 'manual_adjustment',
          oldQty: oldStock,
          newQty: newStock,
          reason: `Sale ${sale.sale_number} cancelled`,
          referenceId: sale.id,
          referenceType: 'sale',
          transaction,
        });
      }
    }

    await sale.update({ is_cancelled: true }, { transaction });
    await transaction.commit();

    res.json({ success: true, message: 'Sale cancelled and stock restored' });
  } catch (err) {
    await transaction.rollback();
    console.error('Error cancelling sale:', err);
    res.status(500).json({ success: false, message: 'Failed to cancel sale' });
  }
});

module.exports = router;

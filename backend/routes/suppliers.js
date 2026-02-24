// backend/routes/suppliers.js
const express = require("express");
const router = express.Router();
const { body, query, validationResult } = require("express-validator");
const { authenticateToken, checkSubscription } = require("../middleware/auth");
const db = require("../models");

const CITIES = ["Casablanca","Rabat","Marrakech","Agadir","Tangier","Fes","Meknes","Other"];
const CONTACT_METHODS = ["whatsapp","phone","email"];
const PHONE_REGEX = /^\+212[5-7]\d{8}$/;

const validateSupplier = [
  body("name").notEmpty().isLength({ min: 2, max: 100 }).withMessage("Supplier name must be 2-100 characters"),
  body("phone_number").matches(PHONE_REGEX).withMessage("Invalid Morocco phone number. Use +212XXXXXXXXX format"),
  body("business_name").optional().isLength({ min: 2, max: 100 }).withMessage("Business name must be 2-100 characters"),
  body("email").optional().isEmail().withMessage("Invalid email format"),
  body("address").optional().isLength({ max: 500 }).withMessage("Address too long"),
  body("city").optional().isIn(CITIES).withMessage("Invalid city"),
  body("preferred_contact_method").optional().isIn(CONTACT_METHODS).withMessage("Invalid contact method"),
  body("payment_terms").optional().isLength({ max: 100 }).withMessage("Payment terms too long"),
  body("merchant_notes").optional().isLength({ max: 500 }).withMessage("Notes too long"),
];

const validateSupplierUpdate = [
  body("name").optional().isLength({ min: 2, max: 100 }).withMessage("Supplier name must be 2-100 characters"),
  body("phone_number").optional().matches(PHONE_REGEX).withMessage("Invalid Morocco phone number. Use +212XXXXXXXXX format"),
  body("business_name").optional().isLength({ min: 2, max: 100 }).withMessage("Business name must be 2-100 characters"),
  body("email").optional().isEmail().withMessage("Invalid email format"),
  body("address").optional().isLength({ max: 500 }).withMessage("Address too long"),
  body("city").optional().isIn(CITIES).withMessage("Invalid city"),
  body("preferred_contact_method").optional().isIn(CONTACT_METHODS).withMessage("Invalid contact method"),
  body("payment_terms").optional().isLength({ max: 100 }).withMessage("Payment terms too long"),
  body("merchant_notes").optional().isLength({ max: 500 }).withMessage("Notes too long"),
];

const validateSuppliersQuery = [
  query("search").optional().isLength({ max: 100 }).withMessage("Search query too long").trim(),
  query("city").optional().isIn(CITIES).withMessage("Invalid city"),
];

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ success: false, message: "Validation failed", errors: errors.array() });
  next();
};

function formatSupplier(s) {
  return {
    id: s.id, name: s.name, business_name: s.business_name, phone_number: s.phone_number,
    email: s.email, address: s.address, city: s.city, supplier_type: s.supplier_type,
    avatar_url: s.avatar_url || null,
    relationship: {
      preferred_contact_method: s.preferred_contact_method,
      payment_terms: s.payment_terms,
      merchant_notes: s.merchant_notes,
      last_order_date: s.last_order_date,
      total_orders: s.total_orders || 0,
      linked_since: s.created_at,
    },
  };
}

// GET / -- list
router.get("/", authenticateToken, validateSuppliersQuery, handleValidationErrors, async (req, res) => {
  try {
    const { search, city } = req.query;
    const where = { merchant_id: req.merchantId, is_active: true };
    if (city) where.city = city;
    if (search && search.trim()) {
      const term = search.trim();
      where[db.Sequelize.Op.or] = [
        { name: { [db.Sequelize.Op.like]: "%" + term + "%" } },
        { business_name: { [db.Sequelize.Op.like]: "%" + term + "%" } },
        { phone_number: { [db.Sequelize.Op.like]: "%" + term + "%" } },
      ];
    }
    const suppliers = await db.Supplier.findAll({
      where,
      order: [["name", "ASC"]],
      include: [{
        model: db.PurchaseOrder,
        as: 'purchase_orders',
        attributes: [],
        where: { is_active: true },
        required: false,
      }],
      attributes: {
        include: [[db.Sequelize.fn('COUNT', db.Sequelize.col('purchase_orders.id')), 'order_count']],
      },
      group: ['Supplier.id'],
    });
    res.json({ success: true, data: {
      suppliers: suppliers.map(s => ({
        ...formatSupplier(s),
        relationship: {
          ...formatSupplier(s).relationship,
          total_orders: parseInt(s.dataValues.order_count ?? 0, 10),
        },
      })),
      meta: { total: suppliers.length, search: (search && search.trim()) ? search.trim() : null, city: city || null },
    }});
  } catch (error) {
    console.error("Error fetching suppliers:", error);
    res.status(500).json({ success: false, message: "Failed to fetch suppliers", error: process.env.NODE_ENV === "development" ? error.message : "Internal server error" });
  }
});

// POST / -- create
router.post("/", authenticateToken, checkSubscription, validateSupplier, handleValidationErrors, async (req, res) => {
  try {
    const { name, phone_number, business_name, email, address, city, preferred_contact_method = "whatsapp", payment_terms, merchant_notes } = req.body;
    const existing = await db.Supplier.findOne({ where: { merchant_id: req.merchantId, phone_number: phone_number.trim(), is_active: true } });
    if (existing) return res.status(400).json({ success: false, message: "You already have a supplier with this phone number", code: "SUPPLIER_ALREADY_EXISTS" });
    const supplier = await db.Supplier.create({
      merchant_id: req.merchantId,
      name: name.trim(), phone_number: phone_number.trim(),
      business_name: business_name ? business_name.trim() : null,
      email: email ? email.trim() : null,
      address: address ? address.trim() : null,
      city: city || null, preferred_contact_method,
      payment_terms: payment_terms ? payment_terms.trim() : null,
      merchant_notes: merchant_notes ? merchant_notes.trim() : null,
    });
    console.log("Created supplier:", supplier.name, "for merchant", req.merchantId);
    res.status(201).json({ success: true, message: "Supplier created", data: {
      supplier: { id: supplier.id, name: supplier.name, business_name: supplier.business_name, phone_number: supplier.phone_number, email: supplier.email, address: supplier.address, city: supplier.city, is_new_supplier: true },
      relationship: { preferred_contact_method: supplier.preferred_contact_method, payment_terms: supplier.payment_terms, merchant_notes: supplier.merchant_notes, created_at: supplier.created_at },
    }});
  } catch (error) {
    console.error("Error creating supplier:", error);
    if (error.name === "SequelizeUniqueConstraintError") return res.status(400).json({ success: false, message: "You already have a supplier with this phone number", code: "SUPPLIER_ALREADY_EXISTS" });
    res.status(500).json({ success: false, message: "Failed to create supplier", error: process.env.NODE_ENV === "development" ? error.message : "Internal server error" });
  }
});

// GET /:id -- detail
router.get("/:id", authenticateToken, async (req, res) => {
  try {
    const supplier = await db.Supplier.findOne({ where: { id: req.params.id, merchant_id: req.merchantId, is_active: true } });
    if (!supplier) return res.status(404).json({ success: false, message: "Supplier not found" });
    const orders = await db.PurchaseOrder.findAll({
      where: { merchant_id: req.merchantId, supplier_id: supplier.id, is_active: true },
      order: [["created_at", "DESC"]], limit: 10,
      attributes: ["id", "order_number", "pdf_generated_at", "sent_at", "created_at"],
    });
    res.json({ success: true, data: {
      supplier: formatSupplier(supplier),
      recent_orders: orders.map(o => ({ id: o.id, order_number: o.order_number, created_at: o.created_at, pdf_generated: !!o.pdf_generated_at, sent: !!o.sent_at })),
    }});
  } catch (error) {
    console.error("Error fetching supplier:", error);
    res.status(500).json({ success: false, message: "Failed to fetch supplier", error: process.env.NODE_ENV === "development" ? error.message : "Internal server error" });
  }
});

// PUT /:id -- update
router.put("/:id", authenticateToken, validateSupplierUpdate, handleValidationErrors, async (req, res) => {
  try {
    const supplier = await db.Supplier.findOne({ where: { id: req.params.id, merchant_id: req.merchantId, is_active: true } });
    if (!supplier) return res.status(404).json({ success: false, message: "Supplier not found" });
    const { name, phone_number, business_name, email, address, city, preferred_contact_method, payment_terms, merchant_notes } = req.body;
    const upd = {};
    if (name !== undefined) upd.name = name.trim();
    if (phone_number !== undefined) upd.phone_number = phone_number.trim();
    if (business_name !== undefined) upd.business_name = business_name ? business_name.trim() : null;
    if (email !== undefined) upd.email = email ? email.trim() : null;
    if (address !== undefined) upd.address = address ? address.trim() : null;
    if (city !== undefined) upd.city = city || null;
    if (preferred_contact_method !== undefined) upd.preferred_contact_method = preferred_contact_method;
    if (payment_terms !== undefined) upd.payment_terms = payment_terms ? payment_terms.trim() : null;
    if (merchant_notes !== undefined) upd.merchant_notes = merchant_notes ? merchant_notes.trim() : null;
    await supplier.update(upd);
    console.log("Updated supplier:", supplier.name);
    res.json({ success: true, message: "Supplier updated successfully", data: { supplier: formatSupplier(supplier) } });
  } catch (error) {
    console.error("Error updating supplier:", error);
    if (error.name === "SequelizeUniqueConstraintError") return res.status(400).json({ success: false, message: "You already have a supplier with this phone number", code: "SUPPLIER_ALREADY_EXISTS" });
    res.status(500).json({ success: false, message: "Failed to update supplier", error: process.env.NODE_ENV === "development" ? error.message : "Internal server error" });
  }
});

// DELETE /:id -- soft delete
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    const supplier = await db.Supplier.findOne({ where: { id: req.params.id, merchant_id: req.merchantId, is_active: true } });
    if (!supplier) return res.status(404).json({ success: false, message: "Supplier not found" });
    const orderCount = await db.PurchaseOrder.count({ where: { merchant_id: req.merchantId, supplier_id: req.params.id, is_active: true } });
    if (orderCount > 0) return res.status(400).json({ success: false, message: "Cannot remove supplier. You have " + orderCount + " order(s) with this supplier.", code: "SUPPLIER_HAS_ORDERS", order_count: orderCount });
    await supplier.update({ is_active: false });
    console.log("Soft-deleted supplier:", supplier.name);
    res.json({ success: true, message: "Supplier removed successfully" });
  } catch (error) {
    console.error("Error deleting supplier:", error);
    res.status(500).json({ success: false, message: "Failed to remove supplier", error: process.env.NODE_ENV === "development" ? error.message : "Internal server error" });
  }
});

// POST /:id/avatar -- upload supplier avatar
const { uploadAvatar } = require('../middleware/upload');

router.post('/:id/avatar', authenticateToken, uploadAvatar.single('avatar'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No image file provided' });
    }

    const supplier = await db.Supplier.findOne({
      where: { id: req.params.id, merchant_id: req.merchantId, is_active: true }
    });

    if (!supplier) {
      return res.status(404).json({ success: false, message: 'Supplier not found' });
    }

    const avatarUrl = req.file.location; // S3 absolute URL
    await supplier.update({ avatar_url: avatarUrl });

    res.json({ success: true, data: { avatar_url: avatarUrl } });
  } catch (error) {
    console.error('Error uploading supplier avatar:', error);
    res.status(500).json({ success: false, message: 'Failed to upload avatar' });
  }
});

module.exports = router;

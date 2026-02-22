// backend/routes/categories.js
const express = require("express");
const router = express.Router();
const { body, validationResult } = require("express-validator");
const { authenticateToken, checkSubscription } = require("../middleware/auth");
const db = require("../models");

const validateCategory = [
  body("name")
    .notEmpty()
    .isLength({ min: 2, max: 50 })
    .withMessage("Category name must be 2-50 characters"),
  body("color")
    .optional()
    .matches(/^#[0-9A-Fa-f]{6}$/)
    .withMessage("Color must be a valid hex color (e.g. #FF5722)"),
  body("icon")
    .optional()
    .isLength({ max: 30 })
    .withMessage("Icon name too long"),
  body("sort_order")
    .optional()
    .isInt({ min: 0 })
    .withMessage("Sort order must be a non-negative integer"),
];

const validateCategoryUpdate = [
  body("name")
    .optional()
    .isLength({ min: 2, max: 50 })
    .withMessage("Category name must be 2-50 characters"),
  body("color")
    .optional()
    .matches(/^#[0-9A-Fa-f]{6}$/)
    .withMessage("Color must be a valid hex color (e.g. #FF5722)"),
  body("icon")
    .optional()
    .isLength({ max: 30 })
    .withMessage("Icon name too long"),
  body("sort_order")
    .optional()
    .isInt({ min: 0 })
    .withMessage("Sort order must be a non-negative integer"),
];

const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors: errors.array(),
    });
  }
  next();
};

/**
 * GET /api/categories
 * List all active categories for the merchant
 */
router.get("/", authenticateToken, async (req, res) => {
  try {
    const categories = await db.Category.findAll({
      where: {
        merchant_id: req.merchantId,
        is_active: true,
      },
      order: [
        ["sort_order", "ASC"],
        ["name", "ASC"],
      ],
      attributes: ["id", "name", "color", "icon", "sort_order", "created_at", "updated_at"],
    });

    res.json({
      success: true,
      data: {
        categories: categories.map((c) => c.toJSON()),
        meta: { total: categories.length },
      },
    });
  } catch (error) {
    console.error("Error fetching categories:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch categories",
      error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
    });
  }
});

/**
 * POST /api/categories
 * Create a new category
 */
router.post("/", authenticateToken, checkSubscription, validateCategory, handleValidationErrors, async (req, res) => {
  try {
    const { name, color, icon, sort_order } = req.body;

    // Check for duplicate name for this merchant
    const existing = await db.Category.findOne({
      where: {
        merchant_id: req.merchantId,
        name: name.trim(),
        is_active: true,
      },
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: "A category with this name already exists",
        code: "DUPLICATE_CATEGORY_NAME",
      });
    }

    const category = await db.Category.create({
      merchant_id: req.merchantId,
      name: name.trim(),
      color: color || null,
      icon: icon || null,
      sort_order: sort_order ?? 0,
    });

    console.log(`Created category: ${category.name} for merchant ${req.merchantId}`);

    res.status(201).json({
      success: true,
      message: "Category created",
      data: {
        category: {
          id: category.id,
          name: category.name,
          color: category.color,
          icon: category.icon,
          sort_order: category.sort_order,
          created_at: category.created_at,
          updated_at: category.updated_at,
        },
      },
    });
  } catch (error) {
    console.error("Error creating category:", error);
    if (error.name === "SequelizeUniqueConstraintError") {
      return res.status(400).json({
        success: false,
        message: "A category with this name already exists",
        code: "DUPLICATE_CATEGORY_NAME",
      });
    }
    res.status(500).json({
      success: false,
      message: "Failed to create category",
      error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
    });
  }
});

/**
 * PUT /api/categories/:id
 * Update an existing category
 */
router.put("/:id", authenticateToken, validateCategoryUpdate, handleValidationErrors, async (req, res) => {
  try {
    const category = await db.Category.findOne({
      where: {
        id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true,
      },
    });

    if (!category) {
      return res.status(404).json({ success: false, message: "Category not found" });
    }

    const { name, color, icon, sort_order } = req.body;

    // Check for duplicate name if name is being updated
    if (name && name.trim() !== category.name) {
      const existing = await db.Category.findOne({
        where: {
          merchant_id: req.merchantId,
          name: name.trim(),
          is_active: true,
          id: { [db.Sequelize.Op.ne]: category.id },
        },
      });

      if (existing) {
        return res.status(400).json({
          success: false,
          message: "A category with this name already exists",
          code: "DUPLICATE_CATEGORY_NAME",
        });
      }
    }

    const updateData = {};
    if (name !== undefined) updateData.name = name.trim();
    if (color !== undefined) updateData.color = color || null;
    if (icon !== undefined) updateData.icon = icon || null;
    if (sort_order !== undefined) updateData.sort_order = sort_order;

    await category.update(updateData);

    console.log(`Updated category: ${category.name}`);

    res.json({
      success: true,
      message: "Category updated successfully",
      data: {
        category: {
          id: category.id,
          name: category.name,
          color: category.color,
          icon: category.icon,
          sort_order: category.sort_order,
          created_at: category.created_at,
          updated_at: category.updated_at,
        },
      },
    });
  } catch (error) {
    console.error("Error updating category:", error);
    if (error.name === "SequelizeUniqueConstraintError") {
      return res.status(400).json({
        success: false,
        message: "A category with this name already exists",
        code: "DUPLICATE_CATEGORY_NAME",
      });
    }
    res.status(500).json({
      success: false,
      message: "Failed to update category",
      error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
    });
  }
});

/**
 * DELETE /api/categories/:id
 * Soft delete a category (set is_active=false), reassign products to null
 */
router.delete("/:id", authenticateToken, async (req, res) => {
  try {
    const category = await db.Category.findOne({
      where: {
        id: req.params.id,
        merchant_id: req.merchantId,
        is_active: true,
      },
    });

    if (!category) {
      return res.status(404).json({ success: false, message: "Category not found" });
    }

    // Reassign products in this category to uncategorized (null)
    await db.Product.update(
      { category_id: null },
      {
        where: {
          merchant_id: req.merchantId,
          category_id: category.id,
          is_active: true,
        },
      }
    );

    await category.update({ is_active: false });

    console.log(`Soft-deleted category: ${category.name}`);

    res.json({ success: true, message: "Category deleted successfully" });
  } catch (error) {
    console.error("Error deleting category:", error);
    res.status(500).json({
      success: false,
      message: "Failed to delete category",
      error: process.env.NODE_ENV === "development" ? error.message : "Internal server error",
    });
  }
});

/**
 * POST /api/categories/seed-defaults
 * Seeds the standard Moroccan small-seller category list for this merchant.
 * Skips any category whose name already exists (idempotent).
 * Returns { created, skipped } counts.
 */
const DEFAULT_CATEGORIES = [
  // ── Alimentaire / Food ──────────────────────────────────────────
  { name: 'Épicerie & Conserves',   color: '#F59E0B', sort_order:  1 },
  { name: 'Boissons & Eau',         color: '#3B82F6', sort_order:  2 },
  { name: 'Produits Laitiers',      color: '#FDE68A', sort_order:  3 },
  { name: 'Boulangerie & Pâtisserie', color: '#D97706', sort_order: 4 },
  { name: 'Huiles & Graisses',      color: '#FBBF24', sort_order:  5 },
  { name: 'Légumineuses & Céréales',color: '#92400E', sort_order:  6 },
  { name: 'Sucre, Sel & Épices',    color: '#EF4444', sort_order:  7 },
  { name: 'Café, Thé & Infusions',  color: '#6B3F00', sort_order:  8 },
  { name: 'Snacks & Confiseries',   color: '#EC4899', sort_order:  9 },
  { name: 'Fruits & Légumes',       color: '#22C55E', sort_order: 10 },
  { name: 'Viande & Volaille',      color: '#DC2626', sort_order: 11 },
  { name: 'Poisson & Fruits de Mer',color: '#0EA5E9', sort_order: 12 },
  { name: 'Surgelés',               color: '#7DD3FC', sort_order: 13 },

  // ── Droguerie / Hygiène ─────────────────────────────────────────
  { name: 'Hygiène & Beauté',       color: '#A78BFA', sort_order: 14 },
  { name: 'Produits Ménagers',      color: '#34D399', sort_order: 15 },
  { name: 'Lessive & Entretien',    color: '#6EE7B7', sort_order: 16 },

  // ── Bébé / Maison ───────────────────────────────────────────────
  { name: 'Bébé & Puériculture',    color: '#F9A8D4', sort_order: 17 },
  { name: 'Articles Ménagers',      color: '#94A3B8', sort_order: 18 },

  // ── Tabac & Télécom ─────────────────────────────────────────────
  { name: 'Tabac & Accessoires',    color: '#78716C', sort_order: 19 },
  { name: 'Recharge & Télécom',     color: '#06B6D4', sort_order: 20 },

  // ── Fournitures ─────────────────────────────────────────────────
  { name: 'Papeterie & Scolaire',   color: '#F472B6', sort_order: 21 },

  // ── Autres ──────────────────────────────────────────────────────
  { name: 'Autres',                 color: '#9CA3AF', sort_order: 22 },
];

router.post('/seed-defaults', authenticateToken, async (req, res) => {
  try {
    // Fetch existing category names for this merchant (case-insensitive check)
    const existing = await db.Category.findAll({
      where: { merchant_id: req.merchantId, is_active: true },
      attributes: ['name'],
    });
    const existingNames = new Set(existing.map(c => c.name.toLowerCase()));

    const toCreate = DEFAULT_CATEGORIES.filter(
      c => !existingNames.has(c.name.toLowerCase())
    );

    if (toCreate.length > 0) {
      await db.Category.bulkCreate(
        toCreate.map(c => ({
          merchant_id: req.merchantId,
          name: c.name,
          color: c.color,
          sort_order: c.sort_order,
        }))
      );
    }

    const skipped = DEFAULT_CATEGORIES.length - toCreate.length;

    res.json({
      success: true,
      message: `Default categories seeded: ${toCreate.length} created, ${skipped} already existed`,
      data: { created: toCreate.length, skipped },
    });
  } catch (error) {
    console.error('Error seeding default categories:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to seed categories',
      error: process.env.NODE_ENV === 'development' ? error.message : 'Internal server error',
    });
  }
});

module.exports = router;

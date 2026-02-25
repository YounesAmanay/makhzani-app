// backend/routes/reports.js
const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const db = require('../models');

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Resolve date range from query params.
 * period: today | week | month | last_month | custom
 * For custom: from=YYYY-MM-DD&to=YYYY-MM-DD
 */
function resolveDateRange(query) {
  const now = new Date();
  let from, to;

  to = new Date(now);
  to.setHours(23, 59, 59, 999);

  switch (query.period) {
    case 'today':
      from = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      break;
    case 'week':
      from = new Date(now);
      from.setDate(from.getDate() - 6);
      from.setHours(0, 0, 0, 0);
      break;
    case 'last_month':
      from = new Date(now.getFullYear(), now.getMonth() - 1, 1);
      to = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59, 999);
      break;
    case 'custom':
      if (!query.from || !query.to) {
        return null; // invalid
      }
      from = new Date(query.from);
      from.setHours(0, 0, 0, 0);
      to = new Date(query.to);
      to.setHours(23, 59, 59, 999);
      break;
    case 'month':
    default:
      from = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
  }

  return { from, to };
}

// ─── GET /api/reports/sales ───────────────────────────────────────────────────

router.get('/sales', authenticateToken, async (req, res) => {
  try {
    const merchantId = req.merchantId;
    const range = resolveDateRange(req.query);

    if (!range) {
      return res.status(400).json({
        success: false,
        message: 'Custom period requires from and to query params (YYYY-MM-DD)',
      });
    }

    const { from, to } = range;

    const [
      summaryRows,
      cancelledRows,
      chartRows,
      topProductRows,
      bestWorstRows,
    ] = await Promise.all([

      // Summary — revenue, count, profit, avg
      db.sequelize.query(`
        SELECT
          COALESCE(SUM(s.total_amount), 0)                                        AS total_revenue,
          COUNT(s.id)                                                              AS total_sales,
          COALESCE(SUM((si.unit_price - p.cost_price) * si.quantity), 0)          AS total_profit,
          COALESCE(AVG(s.total_amount), 0)                                         AS avg_sale_value
        FROM sales s
        LEFT JOIN sale_items si ON si.sale_id = s.id
        LEFT JOIN products p ON p.id = si.product_id AND p.cost_price IS NOT NULL
        WHERE s.merchant_id = :merchantId
          AND s.is_cancelled = false
          AND s.created_at BETWEEN :from AND :to
      `, { replacements: { merchantId, from, to }, type: db.Sequelize.QueryTypes.SELECT }),

      // Cancelled stats
      db.sequelize.query(`
        SELECT
          COUNT(id)                        AS cancelled_count,
          COALESCE(SUM(total_amount), 0)   AS cancelled_value
        FROM sales
        WHERE merchant_id = :merchantId
          AND is_cancelled = true
          AND created_at BETWEEN :from AND :to
      `, { replacements: { merchantId, from, to }, type: db.Sequelize.QueryTypes.SELECT }),

      // Daily chart
      db.sequelize.query(`
        SELECT
          DATE(created_at)               AS date,
          COALESCE(SUM(total_amount), 0) AS revenue,
          COUNT(id)                      AS count
        FROM sales
        WHERE merchant_id = :merchantId
          AND is_cancelled = false
          AND created_at BETWEEN :from AND :to
        GROUP BY DATE(created_at)
        ORDER BY date ASC
      `, { replacements: { merchantId, from, to }, type: db.Sequelize.QueryTypes.SELECT }),

      // Top 10 products by revenue
      db.sequelize.query(`
        SELECT
          si.product_id,
          si.product_name_snapshot                                            AS name,
          COALESCE(SUM(si.total_price), 0)                                    AS revenue,
          COALESCE(SUM(si.quantity), 0)                                       AS quantity,
          COALESCE(SUM((si.unit_price - p.cost_price) * si.quantity), 0)      AS profit
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        LEFT JOIN products p ON p.id = si.product_id AND p.cost_price IS NOT NULL
        WHERE s.merchant_id = :merchantId
          AND s.is_cancelled = false
          AND s.created_at BETWEEN :from AND :to
        GROUP BY si.product_id, si.product_name_snapshot
        ORDER BY revenue DESC
        LIMIT 10
      `, { replacements: { merchantId, from, to }, type: db.Sequelize.QueryTypes.SELECT }),

      // Best and worst day
      db.sequelize.query(`
        SELECT
          DATE(created_at)               AS date,
          COALESCE(SUM(total_amount), 0) AS revenue
        FROM sales
        WHERE merchant_id = :merchantId
          AND is_cancelled = false
          AND created_at BETWEEN :from AND :to
        GROUP BY DATE(created_at)
        ORDER BY revenue DESC
      `, { replacements: { merchantId, from, to }, type: db.Sequelize.QueryTypes.SELECT }),
    ]);

    const summary = summaryRows[0] || {};
    const cancelled = cancelledRows[0] || {};
    const bestDay = bestWorstRows[0] || null;
    const worstDay = bestWorstRows[bestWorstRows.length - 1] || null;

    res.json({
      success: true,
      data: {
        period: {
          from: from.toISOString().split('T')[0],
          to: to.toISOString().split('T')[0],
          label: req.query.period || 'month',
        },
        summary: {
          total_revenue: parseFloat(summary.total_revenue ?? 0),
          total_sales: parseInt(summary.total_sales ?? 0),
          total_profit: parseFloat(summary.total_profit ?? 0),
          avg_sale_value: parseFloat(summary.avg_sale_value ?? 0),
          cancelled_count: parseInt(cancelled.cancelled_count ?? 0),
          cancelled_value: parseFloat(cancelled.cancelled_value ?? 0),
        },
        chart: chartRows.map(r => ({
          date: r.date instanceof Date ? r.date.toISOString().split('T')[0] : r.date,
          revenue: parseFloat(r.revenue),
          count: parseInt(r.count),
        })),
        top_products: topProductRows.map(r => ({
          product_id: r.product_id,
          name: r.name,
          revenue: parseFloat(r.revenue),
          quantity: parseFloat(r.quantity),
          profit: parseFloat(r.profit),
        })),
        best_day: bestDay ? {
          date: bestDay.date instanceof Date ? bestDay.date.toISOString().split('T')[0] : bestDay.date,
          revenue: parseFloat(bestDay.revenue),
        } : null,
        worst_day: worstDay && worstDay !== bestDay ? {
          date: worstDay.date instanceof Date ? worstDay.date.toISOString().split('T')[0] : worstDay.date,
          revenue: parseFloat(worstDay.revenue),
        } : null,
      },
    });

  } catch (error) {
    console.error('Error fetching sales report:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch sales report' });
  }
});

// ─── GET /api/reports/products ────────────────────────────────────────────────

router.get('/products', authenticateToken, async (req, res) => {
  try {
    const merchantId = req.merchantId;
    const deadStockDays = parseInt(req.query.dead_stock_days) || 30;

    const [bestSellersRows, deadStockRows, byCategoryRows] = await Promise.all([

      // Best sellers — all time
      db.sequelize.query(`
        SELECT
          si.product_id,
          si.product_name_snapshot                                            AS name,
          COALESCE(SUM(si.total_price), 0)                                    AS revenue,
          COALESCE(SUM(si.quantity), 0)                                       AS quantity_sold,
          COALESCE(SUM((si.unit_price - p.cost_price) * si.quantity), 0)      AS profit,
          CASE
            WHEN SUM(si.total_price) > 0 AND SUM(p.cost_price * si.quantity) > 0
            THEN ROUND(
              (SUM(si.total_price) - SUM(p.cost_price * si.quantity))
              / SUM(si.total_price) * 100, 1
            )
            ELSE 0
          END AS margin_pct
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id AND s.is_cancelled = false
        LEFT JOIN products p ON p.id = si.product_id
        WHERE s.merchant_id = :merchantId
        GROUP BY si.product_id, si.product_name_snapshot
        ORDER BY revenue DESC
        LIMIT 10
      `, { replacements: { merchantId }, type: db.Sequelize.QueryTypes.SELECT }),

      // Dead stock — products with no sales in last N days
      db.sequelize.query(`
        SELECT
          p.id                                              AS product_id,
          p.name,
          p.current_stock,
          p.unit,
          COALESCE(p.current_stock * p.cost_price, 0)      AS stock_value,
          DATEDIFF(NOW(), MAX(s.created_at))                AS days_since_last_sale
        FROM products p
        LEFT JOIN sale_items si ON si.product_id = p.id
        LEFT JOIN sales s ON s.id = si.sale_id AND s.is_cancelled = false
        WHERE p.merchant_id = :merchantId
          AND p.is_active = true
          AND p.current_stock > 0
        GROUP BY p.id, p.name, p.current_stock, p.unit, p.cost_price
        HAVING days_since_last_sale >= :deadStockDays OR days_since_last_sale IS NULL
        ORDER BY days_since_last_sale DESC
        LIMIT 20
      `, { replacements: { merchantId, deadStockDays }, type: db.Sequelize.QueryTypes.SELECT }),

      // By category — revenue + product count
      db.sequelize.query(`
        SELECT
          COALESCE(c.id, 'uncategorized')     AS category_id,
          COALESCE(c.name, 'Uncategorized')   AS name,
          COALESCE(SUM(si.total_price), 0)    AS revenue,
          COUNT(DISTINCT p.id)                AS product_count
        FROM products p
        LEFT JOIN categories c ON c.id = p.category_id
        LEFT JOIN sale_items si ON si.product_id = p.id
        LEFT JOIN sales s ON s.id = si.sale_id AND s.is_cancelled = false
        WHERE p.merchant_id = :merchantId
          AND p.is_active = true
        GROUP BY c.id, c.name
        ORDER BY revenue DESC
      `, { replacements: { merchantId }, type: db.Sequelize.QueryTypes.SELECT }),
    ]);

    res.json({
      success: true,
      data: {
        best_sellers: bestSellersRows.map(r => ({
          product_id: r.product_id,
          name: r.name,
          revenue: parseFloat(r.revenue),
          quantity_sold: parseFloat(r.quantity_sold),
          profit: parseFloat(r.profit),
          margin_pct: parseFloat(r.margin_pct),
        })),
        dead_stock: deadStockRows.map(r => ({
          product_id: r.product_id,
          name: r.name,
          current_stock: parseInt(r.current_stock),
          unit: r.unit,
          stock_value: parseFloat(r.stock_value),
          days_since_last_sale: r.days_since_last_sale !== null ? parseInt(r.days_since_last_sale) : null,
        })),
        by_category: byCategoryRows.map(r => ({
          category_id: r.category_id,
          name: r.name,
          revenue: parseFloat(r.revenue),
          product_count: parseInt(r.product_count),
        })),
      },
    });

  } catch (error) {
    console.error('Error fetching products report:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch products report' });
  }
});

// ─── GET /api/reports/inventory ───────────────────────────────────────────────

router.get('/inventory', authenticateToken, async (req, res) => {
  try {
    const merchantId = req.merchantId;

    const [overviewRows, byCategoryRows] = await Promise.all([

      // Overview counts + values
      db.sequelize.query(`
        SELECT
          COUNT(*)                                                                        AS total_products,
          SUM(CASE WHEN current_stock > reorder_threshold THEN 1 ELSE 0 END)             AS healthy_stock,
          SUM(CASE WHEN current_stock > 0 AND current_stock <= reorder_threshold THEN 1 ELSE 0 END) AS low_stock,
          SUM(CASE WHEN current_stock = 0 THEN 1 ELSE 0 END)                             AS zero_stock,
          COALESCE(SUM(current_stock * cost_price), 0)                                   AS total_stock_value,
          COALESCE(SUM(
            CASE WHEN current_stock < reorder_threshold
            THEN (reorder_threshold - current_stock) * cost_price
            ELSE 0 END
          ), 0) AS reorder_impact
        FROM products
        WHERE merchant_id = :merchantId
          AND is_active = true
      `, { replacements: { merchantId }, type: db.Sequelize.QueryTypes.SELECT }),

      // By category
      db.sequelize.query(`
        SELECT
          COALESCE(c.id, 'uncategorized')                              AS category_id,
          COALESCE(c.name, 'Uncategorized')                            AS name,
          COALESCE(SUM(p.current_stock * p.cost_price), 0)             AS stock_value,
          COUNT(p.id)                                                  AS product_count,
          SUM(CASE WHEN p.current_stock <= p.reorder_threshold THEN 1 ELSE 0 END) AS low_stock_count
        FROM products p
        LEFT JOIN categories c ON c.id = p.category_id
        WHERE p.merchant_id = :merchantId
          AND p.is_active = true
        GROUP BY c.id, c.name
        ORDER BY stock_value DESC
      `, { replacements: { merchantId }, type: db.Sequelize.QueryTypes.SELECT }),
    ]);

    const overview = overviewRows[0] || {};
    const total = parseInt(overview.total_products ?? 0);
    const healthy = parseInt(overview.healthy_stock ?? 0);
    const healthScore = total > 0 ? Math.round((healthy / total) * 100) : 0;

    res.json({
      success: true,
      data: {
        total_products: total,
        healthy_stock: healthy,
        low_stock: parseInt(overview.low_stock ?? 0),
        zero_stock: parseInt(overview.zero_stock ?? 0),
        total_stock_value: parseFloat(overview.total_stock_value ?? 0),
        reorder_impact: parseFloat(overview.reorder_impact ?? 0),
        health_score: healthScore,
        by_category: byCategoryRows.map(r => ({
          category_id: r.category_id,
          name: r.name,
          stock_value: parseFloat(r.stock_value),
          product_count: parseInt(r.product_count),
          low_stock_count: parseInt(r.low_stock_count),
        })),
      },
    });

  } catch (error) {
    console.error('Error fetching inventory report:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch inventory report' });
  }
});

module.exports = router;

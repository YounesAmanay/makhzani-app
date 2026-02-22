const db = require('../models');

/**
 * Log a stock transaction for auditing purposes.
 *
 * @param {Object} params
 * @param {string} params.productId  - UUID of the product
 * @param {string} params.merchantId - UUID of the merchant
 * @param {string} params.type       - One of: manual_adjustment, order_received, wastage, initial_stock, correction
 * @param {number} params.oldQty     - Stock quantity before the change
 * @param {number} params.newQty     - Stock quantity after the change
 * @param {string} [params.reason]   - Optional human-readable reason
 * @param {string} [params.referenceId]   - Optional UUID linking to related record (e.g. order)
 * @param {string} [params.referenceType] - Optional type of the reference (e.g. 'purchase_order')
 * @returns {Promise<Model>} The created StockTransaction record
 */
async function logStockTransaction({
  productId,
  merchantId,
  type,
  oldQty,
  newQty,
  reason,
  referenceId,
  referenceType,
  transaction, // optional — pass when inside an existing DB transaction
}) {
  return db.StockTransaction.create({
    product_id: productId,
    merchant_id: merchantId,
    type,
    old_quantity: oldQty,
    new_quantity: newQty,
    change_amount: newQty - oldQty,
    reason: reason || null,
    reference_id: referenceId || null,
    reference_type: referenceType || null,
  }, transaction ? { transaction } : {});
}

module.exports = { logStockTransaction };

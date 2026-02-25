const { Sequelize } = require('sequelize');
const config = require('../config/database')[process.env.NODE_ENV || 'development'];

// Create sequelize instance
const sequelize = new Sequelize(
  config.database,
  config.username,
  config.password,
  config
);

const db = {};

// Import all models
db.Merchant = require('./Merchant')(sequelize, Sequelize.DataTypes);
db.Supplier = require('./Supplier')(sequelize, Sequelize.DataTypes);
db.Category = require('./Category')(sequelize, Sequelize.DataTypes);
db.Product = require('./Product')(sequelize, Sequelize.DataTypes);
db.PurchaseOrder = require('./PurchaseOrder')(sequelize, Sequelize.DataTypes);
db.PurchaseOrderItem = require('./PurchaseOrderItem')(sequelize, Sequelize.DataTypes);
db.ProductImage = require('./ProductImage')(sequelize, Sequelize.DataTypes);
db.BarcodeCache = require('./BarcodeCache')(sequelize, Sequelize.DataTypes);
db.StockTransaction = require('./StockTransaction')(sequelize, Sequelize.DataTypes);
db.Sale = require('./Sale')(sequelize, Sequelize.DataTypes);
db.SaleItem = require('./SaleItem')(sequelize, Sequelize.DataTypes);

// Create associations
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

// Globally override toJSON on all models so timestamps serialize as snake_case.
// Sequelize underscored:true maps DB created_at → JS createdAt, but toJSON()
// still outputs camelCase. This ensures every model response matches the Flutter contract.
Object.keys(db).forEach(modelName => {
  const model = db[modelName];
  if (!model || !model.prototype) return;
  const originalToJSON = model.prototype.toJSON;
  model.prototype.toJSON = function () {
    const obj = originalToJSON.call(this);
    if ('createdAt' in obj) { obj.created_at = obj.createdAt; delete obj.createdAt; }
    if ('updatedAt' in obj) { obj.updated_at = obj.updatedAt; delete obj.updatedAt; }
    return obj;
  };
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
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
db.MerchantSupplier = require('./MerchantSupplier')(sequelize, Sequelize.DataTypes);
db.Product = require('./Product')(sequelize, Sequelize.DataTypes);
db.PurchaseOrder = require('./PurchaseOrder')(sequelize, Sequelize.DataTypes);
db.PurchaseOrderItem = require('./PurchaseOrderItem')(sequelize, Sequelize.DataTypes);

// Create associations
Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize, DataTypes) => {
  const SaleItem = sequelize.define('SaleItem', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true,
    },
    sale_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'sales', key: 'id' },
    },
    product_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'products', key: 'id' },
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 3),
      allowNull: false,
      validate: { min: 0.001 },
    },
    unit_price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      validate: { min: 0 },
    },
    total_price: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false,
      validate: { min: 0 },
    },
    product_name_snapshot: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    product_unit_snapshot: {
      type: DataTypes.STRING(20),
      allowNull: false,
      defaultValue: 'piece',
    },
  }, {
    tableName: 'sale_items',
    indexes: [
      { fields: ['sale_id'] },
      { fields: ['product_id'] },
    ],
    hooks: {
      beforeCreate: async (item, options) => {
        // Populate snapshots
        if (!item.product_name_snapshot) {
          const product = await sequelize.models.Product.findByPk(
            item.product_id,
            { transaction: options.transaction }
          );
          item.product_name_snapshot = product?.name ?? 'Unknown';
          item.product_unit_snapshot = product?.unit ?? 'piece';
        }
        // Always compute total
        item.total_price = parseFloat(item.quantity) * parseFloat(item.unit_price);
      },
    },
  });

  SaleItem.associate = function (models) {
    SaleItem.belongsTo(models.Sale, { foreignKey: 'sale_id', as: 'sale' });
    SaleItem.belongsTo(models.Product, { foreignKey: 'product_id', as: 'product' });
  };

  return SaleItem;
};

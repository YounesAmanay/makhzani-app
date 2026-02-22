const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize, DataTypes) => {
  const Sale = sequelize.define('Sale', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true,
    },
    merchant_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'merchants', key: 'id' },
    },
    sale_number: {
      type: DataTypes.STRING(20),
      allowNull: true,
    },
    total_items: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      validate: { min: 0 },
    },
    total_amount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false,
      defaultValue: 0,
      validate: { min: 0 },
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    is_cancelled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
  }, {
    tableName: 'sales',
    indexes: [
      { fields: ['merchant_id'] },
      { fields: ['created_at'] },
      { fields: ['merchant_id', 'created_at'] },
      { unique: true, fields: ['merchant_id', 'sale_number'] },
    ],
    hooks: {
      beforeCreate: async (sale, options) => {
        if (!sale.sale_number) {
          try {
            const merchant = await sequelize.models.Merchant.findByPk(
              sale.merchant_id,
              { transaction: options.transaction }
            );
            if (!merchant) throw new Error('Merchant not found');

            const lastSale = await Sale.findOne({
              where: { merchant_id: sale.merchant_id },
              order: [['created_at', 'DESC']],
              transaction: options.transaction,
            });

            let nextNumber = 1;
            if (lastSale?.sale_number) {
              const parts = lastSale.sale_number.split('-');
              if (parts.length > 1) nextNumber = parseInt(parts[1]) + 1;
            }

            const prefix = merchant.name
              .toUpperCase()
              .replace(/[^A-Z]/g, '')
              .substring(0, 4);

            sale.sale_number = `${prefix}-${String(nextNumber).padStart(3, '0')}`;
          } catch (err) {
            console.error('Error generating sale number:', err.message);
            sale.sale_number = `SALE-${Date.now()}`;
          }
        }
      },
    },
  });

  Sale.associate = function (models) {
    Sale.belongsTo(models.Merchant, { foreignKey: 'merchant_id', as: 'merchant' });
    Sale.hasMany(models.SaleItem, { foreignKey: 'sale_id', as: 'items' });
  };

  return Sale;
};

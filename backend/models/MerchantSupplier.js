const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize, DataTypes) => {
  const MerchantSupplier = sequelize.define('MerchantSupplier', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true
    },
    merchant_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'merchants',
        key: 'id'
      }
    },
    supplier_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'suppliers',
        key: 'id'
      }
    },
    preferred_contact_method: {
      type: DataTypes.ENUM('whatsapp', 'phone', 'email'),
      defaultValue: 'whatsapp'
    },
    merchant_notes: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: 'Private notes about this supplier (only visible to this merchant)'
    },
    payment_terms: {
      type: DataTypes.STRING(100),
      allowNull: true,
      comment: 'e.g., "30 days credit", "cash on delivery"'
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
      comment: 'Whether this merchant still works with this supplier'
    },
    last_order_date: {
      type: DataTypes.DATE,
      allowNull: true,
      comment: 'Last time this merchant ordered from this supplier'
    },
    total_orders: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      comment: 'Count of orders placed with this supplier'
    }
  }, {
    tableName: 'merchant_suppliers',
    indexes: [
      // Composite unique constraint - one relationship per merchant-supplier pair
      {
        unique: true,
        fields: ['merchant_id', 'supplier_id']
      },
      { fields: ['merchant_id'] },
      { fields: ['supplier_id'] },
      { fields: ['is_active'] }
    ]
  });

  MerchantSupplier.associate = function(models) {
    MerchantSupplier.belongsTo(models.Merchant, {
      foreignKey: 'merchant_id',
      as: 'merchant'
    });

    MerchantSupplier.belongsTo(models.Supplier, {
      foreignKey: 'supplier_id',
      as: 'supplier'
    });
  };

  return MerchantSupplier;
};
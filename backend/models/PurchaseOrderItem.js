// backend/models/PurchaseOrderItem.js
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize, DataTypes) => {
  const PurchaseOrderItem = sequelize.define('PurchaseOrderItem', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true
    },
    purchase_order_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'purchase_orders',
        key: 'id'
      }
    },
    product_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'products',
        key: 'id'
      }
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 3),  // Supports 2.5 kg, 0.5 liters, etc.
      allowNull: false,
      validate: {
        min: 0.001,
        isDecimal: true
      }
    },
    unit_price: {
      type: DataTypes.DECIMAL(10, 2),  // Price per unit in MAD
      allowNull: true,  // Merchants might not track prices
      validate: {
        min: 0
      }
    },
    total_price: {
      type: DataTypes.DECIMAL(12, 2),  // quantity * unit_price
      allowNull: true,
      validate: {
        min: 0
      }
    },
    notes: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    // Snapshot fields - preserve product info even if product changes later
    product_name_snapshot: {
      type: DataTypes.STRING(100),
      allowNull: true,
      validate: {
        notEmpty: true
      }
    },
    product_unit_snapshot: {
      type: DataTypes.STRING(20),
      allowNull: true,
      defaultValue: 'piece',
      validate: {
        notEmpty: true
      }
    }
  }, {
    tableName: 'purchase_order_items',
    indexes: [
      { fields: ['purchase_order_id'] },
      { fields: ['product_id'] },
      // Prevent duplicate products in same order
      {
        unique: true,
        fields: ['purchase_order_id', 'product_id']
      }
    ],
    hooks: {
      beforeCreate: async (orderItem, options) => {
        console.log('🔧 PurchaseOrderItem beforeCreate hook triggered');

        // Auto-populate product snapshot fields
        if (!orderItem.product_name_snapshot) {
          try {
            const product = await sequelize.models.Product.findByPk(
              orderItem.product_id,
              { transaction: options.transaction }
            );

            if (product) {
              orderItem.product_name_snapshot = product.name;
              orderItem.product_unit_snapshot = product.unit || 'piece';
              console.log(`📦 Product snapshot: ${product.name} (${product.unit || 'piece'})`);
            } else {
              console.error('❌ Product not found for PurchaseOrderItem');
              orderItem.product_name_snapshot = 'Unknown Product';
              orderItem.product_unit_snapshot = 'piece';
            }
          } catch (error) {
            console.error('❌ Error fetching product for snapshot:', error.message);
            orderItem.product_name_snapshot = 'Unknown Product';
            orderItem.product_unit_snapshot = 'piece';
          }
        }

        // Calculate total price if unit price provided
        if (orderItem.unit_price && orderItem.quantity) {
          orderItem.total_price = orderItem.quantity * orderItem.unit_price;
          console.log(`💰 Calculated total: ${orderItem.total_price}`);
        }
      },
      beforeUpdate: async (orderItem) => {
        // Recalculate total price when quantity or unit_price changes
        if (orderItem.unit_price && orderItem.quantity) {
          orderItem.total_price = orderItem.quantity * orderItem.unit_price;
        }
      }
    }
  });

  PurchaseOrderItem.associate = function(models) {
    PurchaseOrderItem.belongsTo(models.PurchaseOrder, {
      foreignKey: 'purchase_order_id',
      as: 'purchase_order'
    });

    PurchaseOrderItem.belongsTo(models.Product, {
      foreignKey: 'product_id',
      as: 'product'
    });
  };

  return PurchaseOrderItem;
};
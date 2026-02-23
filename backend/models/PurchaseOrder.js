module.exports = (sequelize, DataTypes) => {
  const PurchaseOrder = sequelize.define('PurchaseOrder', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
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
    order_number: {
      type: DataTypes.STRING(20),
      allowNull: true,
      validate: {
        notEmpty: true
      }
    },
    total_items: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      validate: {
        min: 0
      }
    },
    total_products: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      validate: {
        min: 0
      }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    pdf_url: {
      type: DataTypes.STRING(500),
      allowNull: true
    },
    pdf_generated_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    sent_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    sent_via: {
      type: DataTypes.ENUM('whatsapp', 'email', 'phone', 'other'),
      allowNull: true
    },
    received_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'purchase_orders',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['merchant_id'] },
      { fields: ['supplier_id'] },
      { fields: ['order_number'] },
      { fields: ['pdf_generated_at'] },
      { fields: ['is_active'] },
      // Composite index for merchant's orders
      { fields: ['merchant_id', 'is_active'] },
      // Unique order number per merchant
      {
        unique: true,
        fields: ['merchant_id', 'order_number']
      }
    ],
    hooks: {
      beforeCreate: async (purchaseOrder, options) => {
        console.log('🔧 PurchaseOrder beforeCreate hook triggered');
        console.log('💾 Current order_number:', purchaseOrder.order_number);

        // Only generate order number if not provided
        if (!purchaseOrder.order_number) {
          try {
            // Get the merchant info
            const merchant = await sequelize.models.Merchant.findByPk(
              purchaseOrder.merchant_id,
              { transaction: options.transaction }
            );

            if (!merchant) {
              throw new Error('Merchant not found');
            }

            // Find the last order for this merchant
            const lastOrder = await PurchaseOrder.findOne({
              where: {
                merchant_id: purchaseOrder.merchant_id,
                is_active: true
              },
              order: [['created_at', 'DESC']],
              transaction: options.transaction
            });

            // Calculate next order number
            let nextNumber = 1;
            if (lastOrder && lastOrder.order_number) {
              const parts = lastOrder.order_number.split('-');
              if (parts.length > 1) {
                nextNumber = parseInt(parts[1]) + 1;
              }
            }

            // Generate order number: AHMED-001, AHMED-002, etc.
            const merchantPrefix = merchant.name
              .toUpperCase()
              .replace(/[^A-Z]/g, '') // Remove non-letters
              .substring(0, 6); // Max 6 characters

            purchaseOrder.order_number = `${merchantPrefix}-${String(nextNumber).padStart(3, '0')}`;

            console.log(`🔢 Generated order number: ${purchaseOrder.order_number}`);

          } catch (error) {
            console.error('❌ Error generating order number:', error.message);
            // Fallback order number if generation fails
            purchaseOrder.order_number = `ORD-${Date.now()}`;
          }
        }
      }
    }
  });

  PurchaseOrder.associate = function(models) {
    PurchaseOrder.belongsTo(models.Merchant, {
      foreignKey: 'merchant_id',
      as: 'merchant'
    });

    PurchaseOrder.belongsTo(models.Supplier, {
      foreignKey: 'supplier_id',
      as: 'supplier'
    });

    PurchaseOrder.hasMany(models.PurchaseOrderItem, {
      foreignKey: 'purchase_order_id',
      as: 'items'
    });
  };

  return PurchaseOrder;
};
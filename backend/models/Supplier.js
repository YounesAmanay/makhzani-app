// backend/models/Supplier.js
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize, DataTypes) => {
  const Supplier = sequelize.define('Supplier', {
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
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      validate: {
        notEmpty: true,
        len: [2, 100]
      }
    },
    business_name: {
      type: DataTypes.STRING(100),
      allowNull: true,
      validate: {
        len: [2, 100]
      }
    },
    phone_number: {
      type: DataTypes.STRING(15),
      allowNull: false,
      validate: {
        isPhoneNumber(value) {
          const phoneRegex = /^\+212[5-7]\d{8}$/;
          if (!phoneRegex.test(value)) {
            throw new Error('Invalid Morocco phone number. Use +212XXXXXXXXX format');
          }
        }
      }
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: true,
      validate: {
        isEmail: true
      }
    },
    address: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    city: {
      type: DataTypes.STRING(50),
      allowNull: true,
      validate: {
        isIn: [['Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other']]
      }
    },
    supplier_type: {
      type: DataTypes.ENUM('wholesaler', 'distributor', 'manufacturer', 'local_supplier'),
      defaultValue: 'wholesaler'
    },
    // Relationship metadata (previously in MerchantSupplier junction table)
    preferred_contact_method: {
      type: DataTypes.ENUM('whatsapp', 'phone', 'email'),
      defaultValue: 'whatsapp',
      allowNull: true
    },
    payment_terms: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    merchant_notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    last_order_date: {
      type: DataTypes.DATE,
      allowNull: true
    },
    total_orders: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    avatar_url: {
      type: DataTypes.STRING(500),
      allowNull: true
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'suppliers',
    indexes: [
      // Scoped uniqueness: same merchant cannot have two suppliers with the same phone
      { unique: true, fields: ['merchant_id', 'phone_number'] },
      { fields: ['merchant_id'] },
      { fields: ['city'] },
      { fields: ['is_active'] }
    ]
  });

  Supplier.associate = function(models) {
    Supplier.belongsTo(models.Merchant, {
      foreignKey: 'merchant_id',
      as: 'merchant'
    });

    Supplier.hasMany(models.PurchaseOrder, {
      foreignKey: 'supplier_id',
      as: 'purchase_orders'
    });
  };

  return Supplier;
};

// backend/models/Supplier.js
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize, DataTypes) => {
  const Supplier = sequelize.define('Supplier', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true
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
      unique: true,  // Keep unique - we'll handle duplicates in business logic
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
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    supplier_type: {
      type: DataTypes.ENUM('wholesaler', 'distributor', 'manufacturer', 'local_supplier'),
      defaultValue: 'wholesaler'
    }
  }, {
    tableName: 'suppliers',
    indexes: [
      { fields: ['phone_number'] },
      { fields: ['name'] },
      { fields: ['city'] },
      { fields: ['is_active'] }
    ]
  });

  Supplier.associate = function(models) {
    // Many-to-Many relationship with Merchants through MerchantSupplier
    Supplier.belongsToMany(models.Merchant, {
      through: models.MerchantSupplier,
      foreignKey: 'supplier_id',
      otherKey: 'merchant_id',
      as: 'merchants'
    });

    // Direct access to the junction table
    Supplier.hasMany(models.MerchantSupplier, {
      foreignKey: 'supplier_id',
      as: 'MerchantSuppliers'
    });

    Supplier.hasMany(models.PurchaseOrder, {
      foreignKey: 'supplier_id',
      as: 'purchase_orders'
    });
  };

  return Supplier;
};
module.exports = (sequelize, DataTypes) => {
  const Product = sequelize.define(
    "Product",
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(100),
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [2, 100],
        },
      },
      current_stock: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
        validate: {
          min: 0,
          isInt: true,
        },
      },
      price: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: true,
        validate: {
          min: 0,
        },
      },
      cost_price: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: true,
        validate: {
          min: 0,
        },
      },
      barcode: {
        type: DataTypes.STRING(50),
        allowNull: true,
        validate: {
          len: [8, 50],
        },
      },
      reorder_threshold: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 5,
        validate: {
          min: 0,
          isInt: true,
        },
      },
      unit: {
        type: DataTypes.STRING(20),
        defaultValue: "piece",
        validate: {
          isIn: [["piece", "kg", "liter", "box", "carton", "bottle"]],
        },
      },
      merchant_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
          model: "merchants",
          key: "id",
        },
      },
      category_id: {
        type: DataTypes.UUID,
        allowNull: true,
        references: {
          model: "categories",
          key: "id",
        },
      },
      is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
      },
    },
    {
      tableName: "products",
      timestamps: true,
      underscored: true,
      indexes: [
        { fields: ["merchant_id"] },
        { fields: ["barcode"] },
        { fields: ["is_active"] },

        { fields: ["merchant_id", "is_active"] },
      ],
    }
  );

  Product.associate = function (models) {
    Product.belongsTo(models.Merchant, {
      foreignKey: "merchant_id",
      as: "merchant",
    });

    Product.belongsTo(models.Category, {
      foreignKey: "category_id",
      as: "category",
    });

    Product.hasMany(models.PurchaseOrderItem, {
      foreignKey: "product_id",
      as: "order_items",
    });

    Product.hasMany(models.ProductImage, {
      foreignKey: "product_id",
      as: "images",
    });
  };

  return Product;
};

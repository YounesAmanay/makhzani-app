const { v4: uuidv4 } = require("uuid");

module.exports = (sequelize, DataTypes) => {
  const StockTransaction = sequelize.define(
    "StockTransaction",
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: () => uuidv4(),
        primaryKey: true,
      },
      product_id: {
        type: DataTypes.UUID,
        allowNull: false,
        references: {
          model: "products",
          key: "id",
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
      type: {
        type: DataTypes.ENUM(
          "manual_adjustment",
          "order_received",
          "wastage",
          "initial_stock",
          "correction"
        ),
        allowNull: false,
      },
      old_quantity: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      new_quantity: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      change_amount: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      reason: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      reference_id: {
        type: DataTypes.UUID,
        allowNull: true,
      },
      reference_type: {
        type: DataTypes.STRING(50),
        allowNull: true,
      },
    },
    {
      tableName: "stock_transactions",
      indexes: [
        { fields: ["product_id"] },
        { fields: ["merchant_id"] },
        { fields: ["product_id", "created_at"] },
      ],
    }
  );

  StockTransaction.associate = function (models) {
    StockTransaction.belongsTo(models.Product, {
      foreignKey: "product_id",
      as: "product",
    });
    StockTransaction.belongsTo(models.Merchant, {
      foreignKey: "merchant_id",
      as: "merchant",
    });
  };

  return StockTransaction;
};

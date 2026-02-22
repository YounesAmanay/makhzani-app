const { v4: uuidv4 } = require("uuid");

module.exports = (sequelize, DataTypes) => {
  const Merchant = sequelize.define(
    "Merchant",
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: () => uuidv4(),
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
      email: {
        type: DataTypes.STRING(100),
        allowNull: true,
        unique: true,
        validate: {
          isEmail: true,
        },
      },
      shop_name: {
        type: DataTypes.STRING(100),
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [2, 100],
        },
      },
      phone_number: {
        type: DataTypes.STRING(15),
        allowNull: false,
        unique: true,
        validate: {
          isPhoneNumber(value) {
            // Morocco phone number: +212 followed by 9 digits
            const phoneRegex = /^\+212[5-7]\d{8}$/;
            if (!phoneRegex.test(value)) {
              throw new Error(
                "Invalid Morocco phone number. Use +212XXXXXXXXX format"
              );
            }
          },
        },
      },
      address: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      region: {
        type: DataTypes.ENUM(
          "Casablanca",
          "Rabat",
          "Marrakech",
          "Agadir",
          "Tangier",
          "Fes",
          "Meknes",
          "Other"
        ),
        allowNull: true,
      },
      status: {
        type: DataTypes.ENUM("active", "inactive", "banned"),
        defaultValue: "active",
      },
      subscription_status: {
        type: DataTypes.ENUM("trial", "paid", "suspended"),
        defaultValue: "trial",
      },
      onboarded_by: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
      },
      trial_ends_at: {
        type: DataTypes.DATE,
        defaultValue: () => {
          const date = new Date();
          date.setDate(date.getDate() + 30); // 30-day trial
          return date;
        },
      },
      last_login: {
        type: DataTypes.DATE,
        allowNull: true,
      },
      device_info: {
        type: DataTypes.JSON,
        allowNull: true,
      },
      otp_verified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
      },
      avatar_url: {
        type: DataTypes.STRING(500),
        allowNull: true,
      },
      fcm_token: {
        type: DataTypes.STRING(500),
        allowNull: true,
      },
    },
    {
      tableName: "merchants",
      indexes: [
        { fields: ["phone_number"] },
        { fields: ["status"] },
        { fields: ["region"] },
        { fields: ["onboarded_by"] },
      ],
      hooks: {
        beforeCreate: (merchant) => {
          // Normalize phone number format
          if (
            merchant.phone_number &&
            !merchant.phone_number.startsWith("+212")
          ) {
            merchant.phone_number =
              "+212" + merchant.phone_number.replace(/^0/, "");
          }
        },
      },
    }
  );
  Merchant.associate = function (models) {
    // One-to-Many: Merchant owns private suppliers
    Merchant.hasMany(models.Supplier, {
      foreignKey: "merchant_id",
      as: "suppliers",
    });

    // One-to-Many: Merchant owns many Products
    Merchant.hasMany(models.Product, {
      foreignKey: "merchant_id",
      as: "products",
    });

    // One-to-Many: Merchant creates many PurchaseOrders
    Merchant.hasMany(models.PurchaseOrder, {
      foreignKey: "merchant_id",
      as: "purchase_orders",
    });
  };

  return Merchant;
};

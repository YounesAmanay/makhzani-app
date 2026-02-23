module.exports = (sequelize, DataTypes) => {
  const Category = sequelize.define(
    "Category",
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(50),
        allowNull: false,
        validate: {
          notEmpty: true,
          len: [2, 50],
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
      color: {
        type: DataTypes.STRING(7),
        allowNull: true,
        validate: {
          is: /^#[0-9A-Fa-f]{6}$/,
        },
      },
      icon: {
        type: DataTypes.STRING(30),
        allowNull: true,
      },
      sort_order: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        validate: {
          isInt: true,
          min: 0,
        },
      },
      is_active: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
      },
    },
    {
      tableName: "categories",
      timestamps: true,
      underscored: true,
      indexes: [
        { fields: ["merchant_id"] },
        { fields: ["merchant_id", "is_active"] },
        {
          unique: true,
          fields: ["merchant_id", "name"],
          where: { is_active: true },
        },
      ],
    }
  );

  Category.associate = function (models) {
    Category.belongsTo(models.Merchant, {
      foreignKey: "merchant_id",
      as: "merchant",
    });

    Category.hasMany(models.Product, {
      foreignKey: "category_id",
      as: "products",
    });
  };

  return Category;
};

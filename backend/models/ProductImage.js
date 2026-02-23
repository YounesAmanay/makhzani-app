// backend/models/ProductImage.js
module.exports = (sequelize, DataTypes) => {
  const ProductImage = sequelize.define('ProductImage', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    product_id: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'products', key: 'id' }
    },
    url: {
      type: DataTypes.STRING(500),
      allowNull: false
    },
    sort_order: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      comment: 'Display order — 0 is the primary image'
    }
  }, {
    tableName: 'product_images',
    timestamps: true,
    underscored: true,
    indexes: [{ fields: ['product_id'] }]
  });

  ProductImage.associate = function(models) {
    ProductImage.belongsTo(models.Product, {
      foreignKey: 'product_id',
      as: 'product'
    });
  };

  return ProductImage;
};

module.exports = (sequelize, DataTypes) => {
  const BarcodeCache = sequelize.define(
    'BarcodeCache',
    {
      barcode: {
        type: DataTypes.STRING(50),
        primaryKey: true,
      },
      name: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      brand: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      quantity_string: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      unit: {
        type: DataTypes.STRING(20),
        allowNull: true,
      },
      unit_value: {
        type: DataTypes.FLOAT,
        allowNull: true,
      },
      category: {
        type: DataTypes.STRING(255),
        allowNull: true,
      },
      image_url: {
        type: DataTypes.STRING(500),
        allowNull: true,
      },
      images_json: {
        type: DataTypes.TEXT,
        allowNull: true,
        get() {
          const raw = this.getDataValue('images_json');
          if (!raw) return [];
          try { return JSON.parse(raw); } catch { return []; }
        },
        set(value) {
          this.setDataValue('images_json', JSON.stringify(value || []));
        },
      },
      source: {
        type: DataTypes.ENUM('openfoodfacts', 'upcitemdb', 'manual'),
        allowNull: false,
      },
      confidence: {
        type: DataTypes.ENUM('high', 'medium', 'low'),
        allowNull: false,
        defaultValue: 'medium',
      },
      looked_up_at: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      expires_at: {
        type: DataTypes.DATE,
        allowNull: false,
      },
    },
    {
      tableName: 'barcode_cache',
      timestamps: false,
      underscored: true,
      indexes: [
        { fields: ['expires_at'] },
      ],
    }
  );

  // No associations — shared cache across all merchants

  return BarcodeCache;
};

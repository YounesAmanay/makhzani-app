'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('barcode_cache', {
      barcode: {
        type: Sequelize.STRING(50),
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      brand: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      quantity_string: {
        type: Sequelize.STRING(100),
        allowNull: true,
      },
      unit: {
        type: Sequelize.STRING(20),
        allowNull: true,
      },
      unit_value: {
        type: Sequelize.FLOAT,
        allowNull: true,
      },
      category: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      image_url: {
        type: Sequelize.STRING(500),
        allowNull: true,
      },
      images_json: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      source: {
        type: Sequelize.ENUM('openfoodfacts', 'upcitemdb', 'manual'),
        allowNull: false,
      },
      confidence: {
        type: Sequelize.ENUM('high', 'medium', 'low'),
        allowNull: false,
        defaultValue: 'medium',
      },
      looked_up_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      expires_at: {
        type: Sequelize.DATE,
        allowNull: false,
      },
    });

    await queryInterface.addIndex('barcode_cache', ['expires_at']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('barcode_cache');
  },
};

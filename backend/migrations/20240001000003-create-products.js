'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('products', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      current_stock: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
      },
      price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      cost_price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      barcode: {
        type: Sequelize.STRING(50),
        allowNull: true,
      },
      reorder_threshold: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 5,
      },
      unit: {
        type: Sequelize.STRING(20),
        defaultValue: 'piece',
      },
      merchant_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'merchants', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      category_id: {
        type: Sequelize.UUID,
        allowNull: true,
        references: { model: 'categories', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'),
      },
    });

    await queryInterface.addIndex('products', ['merchant_id']);
    await queryInterface.addIndex('products', ['barcode']);
    await queryInterface.addIndex('products', ['is_active']);
    await queryInterface.addIndex('products', ['merchant_id', 'is_active']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('products');
  },
};

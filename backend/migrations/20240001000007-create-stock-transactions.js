'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('stock_transactions', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      product_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'products', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      merchant_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'merchants', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      type: {
        type: Sequelize.ENUM('manual_adjustment', 'order_received', 'wastage', 'initial_stock', 'correction', 'sale'),
        allowNull: false,
      },
      old_quantity: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      new_quantity: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      change_amount: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      reason: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      reference_id: {
        type: Sequelize.UUID,
        allowNull: true,
      },
      reference_type: {
        type: Sequelize.STRING(50),
        allowNull: true,
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

    await queryInterface.addIndex('stock_transactions', ['product_id']);
    await queryInterface.addIndex('stock_transactions', ['merchant_id']);
    await queryInterface.addIndex('stock_transactions', ['product_id', 'created_at']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('stock_transactions');
  },
};

'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('purchase_order_items', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      purchase_order_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'purchase_orders', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      product_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'products', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT',
      },
      quantity: {
        type: Sequelize.DECIMAL(10, 3),
        allowNull: false,
      },
      unit_price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true,
      },
      total_price: {
        type: Sequelize.DECIMAL(12, 2),
        allowNull: true,
      },
      notes: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      product_name_snapshot: {
        type: Sequelize.STRING(100),
        allowNull: true,
      },
      product_unit_snapshot: {
        type: Sequelize.STRING(20),
        allowNull: true,
        defaultValue: 'piece',
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

    await queryInterface.addIndex('purchase_order_items', ['purchase_order_id']);
    await queryInterface.addIndex('purchase_order_items', ['product_id']);
    await queryInterface.addIndex('purchase_order_items', {
      fields: ['purchase_order_id', 'product_id'],
      unique: true,
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('purchase_order_items');
  },
};

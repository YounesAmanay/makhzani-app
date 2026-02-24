'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('purchase_orders', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      merchant_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'merchants', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      supplier_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: { model: 'suppliers', key: 'id' },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT',
      },
      order_number: {
        type: Sequelize.STRING(20),
        allowNull: true,
      },
      total_items: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      total_products: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      pdf_url: {
        type: Sequelize.STRING(500),
        allowNull: true,
      },
      pdf_generated_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      sent_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      sent_via: {
        type: Sequelize.ENUM('whatsapp', 'email', 'phone', 'other'),
        allowNull: true,
      },
      received_at: {
        type: Sequelize.DATE,
        allowNull: true,
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

    await queryInterface.addIndex('purchase_orders', ['merchant_id']);
    await queryInterface.addIndex('purchase_orders', ['supplier_id']);
    await queryInterface.addIndex('purchase_orders', ['order_number']);
    await queryInterface.addIndex('purchase_orders', ['pdf_generated_at']);
    await queryInterface.addIndex('purchase_orders', ['is_active']);
    await queryInterface.addIndex('purchase_orders', ['merchant_id', 'is_active']);
    await queryInterface.addIndex('purchase_orders', {
      fields: ['merchant_id', 'order_number'],
      unique: true,
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('purchase_orders');
  },
};

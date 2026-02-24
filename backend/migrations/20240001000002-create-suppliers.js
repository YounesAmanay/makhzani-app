'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('suppliers', {
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
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      business_name: {
        type: Sequelize.STRING(100),
        allowNull: true,
      },
      phone_number: {
        type: Sequelize.STRING(15),
        allowNull: false,
      },
      email: {
        type: Sequelize.STRING(255),
        allowNull: true,
      },
      address: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      city: {
        type: Sequelize.STRING(50),
        allowNull: true,
      },
      supplier_type: {
        type: Sequelize.ENUM('wholesaler', 'distributor', 'manufacturer', 'local_supplier'),
        defaultValue: 'wholesaler',
      },
      preferred_contact_method: {
        type: Sequelize.ENUM('whatsapp', 'phone', 'email'),
        defaultValue: 'whatsapp',
        allowNull: true,
      },
      payment_terms: {
        type: Sequelize.STRING(100),
        allowNull: true,
      },
      merchant_notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      last_order_date: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      total_orders: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      avatar_url: {
        type: Sequelize.STRING(500),
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

    await queryInterface.addIndex('suppliers', ['merchant_id']);
    await queryInterface.addIndex('suppliers', ['city']);
    await queryInterface.addIndex('suppliers', ['is_active']);
    await queryInterface.addIndex('suppliers', { fields: ['merchant_id', 'phone_number'], unique: true });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('suppliers');
  },
};

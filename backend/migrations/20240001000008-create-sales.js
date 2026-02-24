'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('sales', {
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
      sale_number: {
        type: Sequelize.STRING(20),
        allowNull: true,
      },
      total_items: {
        type: Sequelize.INTEGER,
        defaultValue: 0,
      },
      total_amount: {
        type: Sequelize.DECIMAL(12, 2),
        allowNull: false,
        defaultValue: 0,
      },
      notes: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      is_cancelled: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
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

    await queryInterface.addIndex('sales', ['merchant_id']);
    await queryInterface.addIndex('sales', ['created_at']);
    await queryInterface.addIndex('sales', ['merchant_id', 'created_at']);
    await queryInterface.addIndex('sales', {
      fields: ['merchant_id', 'sale_number'],
      unique: true,
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('sales');
  },
};

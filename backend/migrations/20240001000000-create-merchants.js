'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('merchants', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      email: {
        type: Sequelize.STRING(100),
        allowNull: true,
        unique: true,
      },
      shop_name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      phone_number: {
        type: Sequelize.STRING(15),
        allowNull: false,
        unique: true,
      },
      address: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      region: {
        type: Sequelize.ENUM('Casablanca', 'Rabat', 'Marrakech', 'Agadir', 'Tangier', 'Fes', 'Meknes', 'Other'),
        allowNull: true,
      },
      status: {
        type: Sequelize.ENUM('active', 'inactive', 'banned'),
        defaultValue: 'active',
      },
      subscription_status: {
        type: Sequelize.ENUM('trial', 'paid', 'suspended'),
        defaultValue: 'trial',
      },
      onboarded_by: {
        type: Sequelize.STRING(100),
        allowNull: true,
      },
      is_active: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      trial_ends_at: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      last_login: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      device_info: {
        type: Sequelize.JSON,
        allowNull: true,
      },
      otp_verified: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
      },
      avatar_url: {
        type: Sequelize.STRING(500),
        allowNull: true,
      },
      fcm_token: {
        type: Sequelize.STRING(500),
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

    await queryInterface.addIndex('merchants', ['phone_number']);
    await queryInterface.addIndex('merchants', ['status']);
    await queryInterface.addIndex('merchants', ['region']);
    await queryInterface.addIndex('merchants', ['onboarded_by']);
  },

  async down(queryInterface) {
    await queryInterface.dropTable('merchants');
  },
};

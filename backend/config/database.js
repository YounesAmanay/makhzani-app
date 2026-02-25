require('dotenv').config();

module.exports = {
  development: {
    username: 'root',  // Default XAMPP username
    password: '',      // Default XAMPP password (empty)
    database: 'makhzani_db',
    host: 'localhost',
    port: 3306,        // Default MySQL port
    dialect: 'mysql',
    logging: console.log,
    define: {
      underscored: true,
      timestamps: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at'
    }
  },
  test: {
    username: 'root',
    password: '',
    database: 'makhzani_db',
    host: 'localhost',
    port: 3306,
    dialect: 'mysql',
    logging: false
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    dialect: 'mysql',
    logging: false
  }
};
// backend/scripts/clean-test-data.js
const db = require('../models');

async function cleanDatabase() {
  try {
    console.log('🧹 CLEANING ENTIRE DATABASE...\n');

    // Disable foreign key checks first
    console.log('🔧 Disabling foreign key checks...');
    await db.sequelize.query('SET FOREIGN_KEY_CHECKS = 0');

    // Truncate all tables in any order (foreign keys disabled)
    const tables = ['purchase_order_items', 'purchase_orders', 'products', 'merchant_suppliers', 'suppliers', 'merchants'];

    for (const table of tables) {
      console.log(`🗑️ Cleaning table: ${table}`);
      await db.sequelize.query(`TRUNCATE TABLE ${table}`);
      console.log(`✅ Table ${table} cleaned`);
    }

    // Re-enable foreign key checks
    console.log('🔧 Re-enabling foreign key checks...');
    await db.sequelize.query('SET FOREIGN_KEY_CHECKS = 1');

    console.log('\n🎉 ENTIRE DATABASE CLEANED SUCCESSFULLY!');
    console.log('✨ Database is now completely empty and ready for fresh testing');
    console.log('🚀 You can now run: npm run test-all-apis\n');

  } catch (error) {
    console.error('❌ Error cleaning database:', error.message);
    console.error('Stack:', error.stack);
  } finally {
    await db.sequelize.close();
  }
}

cleanDatabase();
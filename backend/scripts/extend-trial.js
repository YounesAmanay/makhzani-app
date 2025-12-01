require('dotenv').config();
const db = require('../models');

async function extendTrial() {
  try {
    // Connect to database
    await db.sequelize.authenticate();
    console.log('✅ Database connected');

    // Get all merchants with expired trials
    const merchants = await db.Merchant.findAll();

    if (merchants.length === 0) {
      console.log('❌ No merchants found');
      process.exit(1);
    }

    console.log(`Found ${merchants.length} merchant(s):\n`);

    for (const merchant of merchants) {
      console.log(`📱 ${merchant.name} (${merchant.phone_number})`);
      console.log(`   Shop: ${merchant.shop_name}`);
      console.log(`   Subscription: ${merchant.subscription_status}`);
      console.log(`   Trial expires: ${merchant.trial_ends_at}`);

      // Extend trial by 30 days
      const newTrialDate = new Date();
      newTrialDate.setDate(newTrialDate.getDate() + 30);

      await merchant.update({
        trial_ends_at: newTrialDate,
        subscription_status: 'trial'
      });

      console.log(`   ✅ Trial extended to: ${newTrialDate.toISOString()}\n`);
    }

    console.log('✅ All trials extended successfully');
    process.exit(0);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

extendTrial();

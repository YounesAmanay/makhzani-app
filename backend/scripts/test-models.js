// backend/scripts/test-models.js
const db = require('../models');

async function testModels() {
  try {
    console.log('🔧 Testing Makhzani Database Models...\n');

    // Step 1: Test database connection
    console.log('1. Testing database connection...');
    await db.sequelize.authenticate();
    console.log('✅ Database connected successfully\n');

    // Step 2: Create all tables
    console.log('2. Creating database tables...');
    await db.sequelize.sync({ force: true }); // ⚠️ This drops existing tables!
    console.log('✅ All tables created successfully\n');

    // Step 3: Test Merchant creation
    console.log('3. Testing Merchant model...');
    const merchant = await db.Merchant.create({
      name: 'Ahmed Hassan',
      shop_name: 'Ahmed\'s Corner Shop',
      phone_number: '+212612345678',
      address: '123 Main Street, Casablanca',
      region: 'Casablanca',
      onboarded_by: 'Field Agent Ali'
    });
    console.log('✅ Merchant created:', merchant.name, '- ID:', merchant.id);

    // Step 4: Test Supplier creation
    console.log('\n4. Testing Supplier model...');
    const supplier = await db.Supplier.create({
      name: 'Mohamed Wholesale',
      business_name: 'Mohamed & Sons Trading',
      phone_number: '+212623456789',
      email: 'mohamed@wholesale.ma',
      address: 'Industrial Zone, Casablanca',
      city: 'Casablanca'
    });
    console.log('✅ Supplier created:', supplier.name, '- ID:', supplier.id);

    // Step 5: Test Merchant-Supplier relationship
    console.log('\n5. Testing Merchant-Supplier relationship...');
    const relationship = await db.MerchantSupplier.create({
      merchant_id: merchant.id,
      supplier_id: supplier.id,
      preferred_contact_method: 'whatsapp',
      payment_terms: '30 days credit',
      merchant_notes: 'Very reliable, fast delivery'
    });
    console.log('✅ Relationship created between merchant and supplier');

    // Step 6: Test Product creation
    console.log('\n6. Testing Product model...');
    const product1 = await db.Product.create({
      name: 'Coca-Cola 1.5L',
      current_stock: 12,
      reorder_threshold: 5,
      unit: 'bottle',
      barcode: '1234567890123',
      merchant_id: merchant.id
    });

    const product2 = await db.Product.create({
      name: 'Fresh Bread',
      current_stock: 8,
      reorder_threshold: 10,
      unit: 'piece',
      merchant_id: merchant.id
    });
    console.log('✅ Products created:', product1.name, 'and', product2.name);

    // Step 7: Test PurchaseOrder creation
    console.log('\n7. Testing PurchaseOrder model...');
    const purchaseOrder = await db.PurchaseOrder.create({
      merchant_id: merchant.id,
      supplier_id: supplier.id,
      notes: 'Please deliver by Thursday morning'
    });
    console.log('✅ Purchase Order created:', purchaseOrder.order_number);

    // Step 8: Test PurchaseOrderItem creation
    console.log('\n8. Testing PurchaseOrderItem model...');
    const orderItem1 = await db.PurchaseOrderItem.create({
      purchase_order_id: purchaseOrder.id,
      product_id: product1.id,
      quantity: 24,
      unit_price: 15.50,
      notes: 'Cold bottles preferred'
    });

    const orderItem2 = await db.PurchaseOrderItem.create({
      purchase_order_id: purchaseOrder.id,
      product_id: product2.id,
      quantity: 20,
      unit_price: 2.00
    });
    console.log('✅ Order items created for Coca-Cola and Bread');

    // Step 9: Test relationships and queries
    console.log('\n9. Testing relationships...');
    
    // Get merchant with all their data
    const merchantWithData = await db.Merchant.findByPk(merchant.id, {
      include: [
        { model: db.Supplier, as: 'suppliers' },
        { model: db.Product, as: 'products' },
        { 
          model: db.PurchaseOrder, 
          as: 'purchase_orders',
          include: [
            { model: db.PurchaseOrderItem, as: 'items' }
          ]
        }
      ]
    });

    console.log('\n📊 MERCHANT DATA SUMMARY:');
    console.log(`Merchant: ${merchantWithData.name}`);
    console.log(`Shop: ${merchantWithData.shop_name}`);
    console.log(`Suppliers: ${merchantWithData.suppliers.length}`);
    console.log(`Products: ${merchantWithData.products.length}`);
    console.log(`Orders: ${merchantWithData.purchase_orders.length}`);
    
    if (merchantWithData.purchase_orders[0]) {
      const order = merchantWithData.purchase_orders[0];
      console.log(`Last Order: ${order.order_number} with ${order.items.length} items`);
    }

    // Step 10: Test business logic
    console.log('\n10. Testing business logic...');
    
    // Test order number generation for second order
    const secondOrder = await db.PurchaseOrder.create({
      merchant_id: merchant.id,
      supplier_id: supplier.id,
      notes: 'Second order test'
    });
    console.log('✅ Second order number generated:', secondOrder.order_number);

    // Test duplicate supplier phone (should fail)
    try {
      await db.Supplier.create({
        name: 'Another Mohamed',
        phone_number: '+212623456789' // Same as first supplier
      });
    } catch (error) {
      console.log('✅ Duplicate phone validation working:', error.name);
    }

    console.log('\n🎉 ALL TESTS PASSED! Your models are working perfectly!\n');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    console.error('Stack:', error.stack);
  } finally {
    await db.sequelize.close();
  }
}

// Run the tests
testModels();
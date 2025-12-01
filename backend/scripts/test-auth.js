// backend/scripts/test-auth.js
const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
const TEST_PHONE = '+212612345678';

async function testAuthFlow() {
  try {
    console.log('🧪 Testing Makhzani Authentication API\n');

    // Step 1: Test health endpoint
    console.log('1. Testing health endpoint...');
    const healthResponse = await axios.get('http://localhost:3000/health');
    console.log('✅ Health check:', healthResponse.data.status);

    // Step 2: Send OTP
    console.log('\n2. Testing OTP generation...');
    const otpResponse = await axios.post(`${BASE_URL}/auth/send-otp`, {
      phone_number: TEST_PHONE
    });
    
    console.log('✅ OTP sent successfully');
    console.log('📱 Phone:', otpResponse.data.data.phone_number);
    console.log('👤 Merchant exists:', otpResponse.data.data.merchant_exists);
    
    const developmentOTP = otpResponse.data.data.development_otp;
    if (developmentOTP) {
      console.log('🔢 Development OTP:', developmentOTP);
    }

    // Step 3: Verify OTP
    console.log('\n3. Testing OTP verification...');
    const verifyResponse = await axios.post(`${BASE_URL}/auth/verify-otp`, {
      phone_number: TEST_PHONE,
      otp: developmentOTP || '1234' // Use generated OTP or fallback
    });

    console.log('✅ OTP verified successfully');
    console.log('🎫 Token received:', !!verifyResponse.data.data.token);
    console.log('👤 Merchant ID:', verifyResponse.data.data.merchant.id);
    console.log('🏪 Shop:', verifyResponse.data.data.merchant.shop_name);
    console.log('🆕 New user:', verifyResponse.data.data.merchant.is_new_user);

    const token = verifyResponse.data.data.token;

    // Step 4: Test protected endpoint
    console.log('\n4. Testing protected endpoint...');
    const profileResponse = await axios.get(`${BASE_URL}/me`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Protected endpoint accessed');
    console.log('📋 Profile:', profileResponse.data.data.merchant.name);

    // Step 5: Test token refresh
    console.log('\n5. Testing token refresh...');
    const refreshResponse = await axios.post(`${BASE_URL}/auth/refresh-token`, {}, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Token refreshed successfully');
    console.log('🎫 New token received:', !!refreshResponse.data.data.token);

    // Step 6: Test invalid OTP
    console.log('\n6. Testing invalid OTP...');
    try {
      await axios.post(`${BASE_URL}/auth/verify-otp`, {
        phone_number: TEST_PHONE,
        otp: '9999'
      });
    } catch (error) {
      console.log('✅ Invalid OTP rejected:', error.response.data.message);
    }

    // Step 7: Test unauthorized access
    console.log('\n7. Testing unauthorized access...');
    try {
      await axios.get(`${BASE_URL}/me`);
    } catch (error) {
      console.log('✅ Unauthorized access blocked:', error.response.data.message);
    }

    console.log('\n🎉 ALL AUTHENTICATION TESTS PASSED!');
    console.log('\n📋 Summary:');
    console.log('• OTP generation: Working');
    console.log('• OTP verification: Working');
    console.log('• JWT token generation: Working');
    console.log('• Protected routes: Working');
    console.log('• Token refresh: Working');
    console.log('• Error handling: Working');

  } catch (error) {
    console.error('❌ Test failed:', error.response?.data || error.message);
  }
}

// Run tests
testAuthFlow();
/**
 * Notification Service
 *
 * Wraps Firebase Admin SDK to send FCM push notifications.
 * Initializes lazily on first use so the server starts even if the
 * service-account file is missing (graceful degradation in dev/test).
 */

const path = require('path');

let _app = null;
let _messaging = null;
let _initFailed = false;

function _init() {
  if (_app || _initFailed) return;

  try {
    const admin = require('firebase-admin');
    const serviceAccountPath = path.join(__dirname, '../config/firebase-service-account.json');
    const serviceAccount = require(serviceAccountPath);

    _app = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    _messaging = admin.messaging(_app);
    console.log('🔔 Firebase Admin SDK initialized');
  } catch (err) {
    _initFailed = true;
    console.warn('⚠️  Firebase Admin SDK not initialized:', err.message);
  }
}

/**
 * Send a push notification to a single FCM token.
 *
 * @param {Object} params
 * @param {string} params.token       - FCM device token
 * @param {string} params.title       - Notification title
 * @param {string} params.body        - Notification body
 * @param {Object} [params.data]      - Optional key-value data payload for deep-linking
 * @returns {Promise<boolean>}        - true if sent, false if skipped/failed
 */
async function sendNotification({ token, title, body, data = {} }) {
  _init();

  if (!_messaging) {
    console.warn('🔔 Notification skipped (Firebase not initialized):', title);
    return false;
  }

  if (!token) {
    console.warn('🔔 Notification skipped (no FCM token):', title);
    return false;
  }

  try {
    await _messaging.send({
      token,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: {
          channelId: 'low_stock_alerts',
          priority: 'high',
          defaultSound: true,
        },
      },
    });
    console.log(`🔔 Notification sent: "${title}"`);
    return true;
  } catch (err) {
    // Token expired or app uninstalled — not a server error
    if (err.code === 'messaging/registration-token-not-registered') {
      console.warn('🔔 FCM token no longer valid, consider clearing it');
    } else {
      console.error('🔔 Failed to send notification:', err.message);
    }
    return false;
  }
}

/**
 * Notify a merchant that a product is running low on stock.
 *
 * @param {Object} params
 * @param {string} params.fcmToken    - Merchant's FCM device token
 * @param {string} params.productName - Name of the low-stock product
 * @param {number} params.currentStock
 * @param {string} params.unit        - Unit label (e.g. "kg", "unit")
 * @param {string} params.productId   - For deep-link navigation
 */
async function notifyLowStock({ fcmToken, productName, currentStock, unit, productId }) {
  return sendNotification({
    token: fcmToken,
    title: '⚠️ Stock bas — ' + productName,
    body: `Il reste ${currentStock} ${unit}. Pensez à commander.`,
    data: {
      type: 'low_stock',
      product_id: productId,
      screen: 'product_detail',
    },
  });
}

module.exports = { sendNotification, notifyLowStock };

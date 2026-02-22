const { createClient } = require('redis');

let redisClient = null;
let redisAvailable = false;

async function getRedisClient() {
  if (redisClient && redisAvailable) return redisClient;

  // Don't retry if we already failed
  if (redisClient && !redisAvailable) return null;

  try {
    redisClient = createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379',
      socket: {
        connectTimeoutMs: 3000,
        reconnectStrategy: false, // Don't auto-retry — fall back to in-memory
      },
    });

    redisClient.on('error', () => {
      // Suppress repeated error logs — handled by connect() catch
      redisAvailable = false;
    });

    await redisClient.connect();
    redisAvailable = true;
    console.log('✅ Redis connected');
    return redisClient;
  } catch (err) {
    console.warn('⚠️ Redis not available, using in-memory OTP storage');
    redisClient = null;
    redisAvailable = false;
    return null;
  }
}

function isRedisAvailable() {
  return redisAvailable;
}

module.exports = { getRedisClient, isRedisAvailable };

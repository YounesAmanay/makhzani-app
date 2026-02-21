const { createClient } = require('redis');

let redisClient = null;
let redisAvailable = false;

async function getRedisClient() {
  if (redisClient && redisAvailable) return redisClient;

  try {
    redisClient = createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379',
    });

    redisClient.on('error', (err) => {
      console.warn('⚠️ Redis error:', err.message);
      redisAvailable = false;
    });

    redisClient.on('connect', () => {
      console.log('✅ Redis connected');
      redisAvailable = true;
    });

    await redisClient.connect();
    redisAvailable = true;
    return redisClient;
  } catch (err) {
    console.warn('⚠️ Redis not available, falling back to in-memory OTP storage:', err.message);
    redisAvailable = false;
    return null;
  }
}

function isRedisAvailable() {
  return redisAvailable;
}

module.exports = { getRedisClient, isRedisAvailable };

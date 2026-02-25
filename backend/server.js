// backend/server.js - Complete with all routes
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const db = require('./models');
const { apiLimiter } = require('./middleware/rateLimiter');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use('/api', apiLimiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

const path = require('path');

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Makhzani API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

// API Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/merchants', require('./routes/merchants'));
// productLookup MUST be mounted before products to prevent /lookup being caught as /:id
app.use('/api/products', require('./routes/productLookup'));
app.use('/api/products', require('./routes/products'));
app.use('/api/suppliers', require('./routes/suppliers'));
app.use('/api/orders', require('./routes/orders'));
app.use('/api/categories', require('./routes/categories'));
app.use('/api/sales', require('./routes/sales'));
app.use('/api/reports', require('./routes/reports'));

// Protected test endpoint
const { authenticateToken } = require('./middleware/auth');
app.get('/api/me', authenticateToken, (req, res) => {
  res.json({
    success: true,
    message: 'Authenticated successfully',
    data: {
      merchant: {
        id: req.merchant.id,
        name: req.merchant.name,
        shop_name: req.merchant.shop_name,
        phone_number: req.merchant.phone_number,
        region: req.merchant.region,
        subscription_status: req.merchant.subscription_status,
        trial_ends_at: req.merchant.trial_ends_at
      }
    }
  });
});

// API documentation endpoint
app.get('/api/docs', (req, res) => {
  res.json({
    success: true,
    message: 'Makhzani API Documentation',
    version: '1.0.0',
    endpoints: {
      authentication: {
        'POST /api/auth/send-otp': 'Send OTP to phone number',
        'POST /api/auth/verify-otp': 'Verify OTP and get JWT token',
        'POST /api/auth/refresh-token': 'Refresh JWT token'
      },
      merchants: {
        'GET /api/merchants/profile': 'Get merchant profile',
        'PUT /api/merchants/profile': 'Update merchant profile',
        'GET /api/merchants/dashboard-stats': 'Get dashboard statistics'
      },
      products: {
        'GET /api/products': 'Get products with pagination and filters',
        'POST /api/products': 'Add new product',
        'GET /api/products/:id': 'Get specific product',
        'PUT /api/products/:id': 'Update product',
        'DELETE /api/products/:id': 'Delete product (soft)',
        'POST /api/products/:id/adjust-stock': 'Adjust product stock'
      },
      suppliers: {
        'GET /api/suppliers': 'Get merchant\'s suppliers',
        'POST /api/suppliers': 'Add/link supplier',
        'GET /api/suppliers/:id': 'Get specific supplier',
        'PUT /api/suppliers/:id': 'Update supplier relationship',
        'DELETE /api/suppliers/:id': 'Remove supplier relationship'
      },
      orders: {
        'GET /api/orders': 'Get purchase orders with filters',
        'POST /api/orders': 'Create new purchase order',
        'GET /api/orders/:id': 'Get specific order details',
        'POST /api/orders/:id/generate-pdf': 'Generate order PDF',
        'POST /api/orders/:id/mark-sent': 'Mark order as sent'
      }
    },
    authentication: 'Include "Authorization: Bearer <token>" header for protected endpoints'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'API endpoint not found',
    path: req.originalUrl,
    available_endpoints: [
      'GET /health',
      'GET /api/docs',
      'POST /api/auth/*',
      'GET|PUT /api/merchants/*',
      'GET|POST|PUT|DELETE /api/products/*',
      'GET|POST|PUT|DELETE /api/suppliers/*',
      'GET|POST /api/orders/*'
    ]
  });
});

// Global error handler
app.use((error, req, res, next) => {
  console.error('Unhandled error:', error);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? {
      message: error.message,
      stack: error.stack
    } : 'Something went wrong'
  });
});

// Database connection and server start
async function startServer() {
  try {
    // Test database connection
    await db.sequelize.authenticate();
    console.log('✅ Database connected successfully');

    // Connect Redis (non-blocking — falls back to in-memory if unavailable)
    const { getRedisClient } = require('./config/redis');
    await getRedisClient().catch(() => {});
    
    // Sync database (only in development)
    if (process.env.NODE_ENV === 'development') {
      await db.sequelize.sync();
      console.log('🔄 Database synchronized');
    }
    
    // Start server - bind to 0.0.0.0 to accept external connections
    app.listen(PORT, '0.0.0.0', () => {
      console.log('\n🚀 MAKHZANI API SERVER STARTED');
      console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🌐 Server: http://localhost:${PORT}`);
      console.log(`📱 Mobile: http://192.168.3.43:${PORT}`);
      console.log(`💚 Health: http://localhost:${PORT}/health`);
      console.log(`📚 Docs: http://localhost:${PORT}/api/docs`);
      console.log('\n📋 Available API Routes:');
      console.log('🔐 Authentication: /api/auth/*');
      console.log('👤 Merchants: /api/merchants/*');
      console.log('📦 Products: /api/products/*');
      console.log('🏪 Suppliers: /api/suppliers/*');
      console.log('📋 Orders: /api/orders/*');
      console.log('\n🧪 Test with: npm run test-all-apis');
    });
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();
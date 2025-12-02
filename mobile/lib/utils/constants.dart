class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.5:3000/api'; // Physical device
  static const String serverUrl = 'http://192.168.1.5:3000'; // Server root for file downloads
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String serverUrl = 'http://10.0.2.2:3000'; // Android emulator server
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String serverUrl = 'http://localhost:3000'; // iOS simulator server

  // App Configuration
  static const String appName = 'Makhzani';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Smart Inventory Partner';

  // Brand Colors - Clean White & Green Palette
  static const primaryGreen = 0xFF10B981; // Modern emerald green
  static const darkGreen = 0xFF059669; // Darker green for accents
  static const lightGreen = 0xFFD1FAE5; // Light green for backgrounds
  static const paleGreen = 0xFFF0FDF4; // Very light green

  static const textDark = 0xFF1F2937; // Dark gray for text
  static const textGray = 0xFF6B7280; // Medium gray for secondary text
  static const textLight = 0xFF9CA3AF; // Light gray for hints

  static const white = 0xFFFFFFFF;
  static const background = 0xFFFAFAFA; // Off-white background
  static const cardBackground = 0xFFFFFFFF;

  static const errorColor = 0xFFEF4444; // Modern red
  static const successColor = 0xFF10B981; // Same as primary green
  static const warningColor = 0xFFF59E0B; // Amber

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String merchantKey = 'merchant_data';

  // Database
  static const String dbName = 'makhzani.db';
  static const int dbVersion = 1;
}

class ApiEndpoints {
  static const String sendOTP = '/auth/send-otp';
  static const String verifyOTP = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String merchantProfile = '/merchants/profile';
  static const String products = '/products';
  static const String suppliers = '/suppliers';
  static const String orders = '/orders';
}
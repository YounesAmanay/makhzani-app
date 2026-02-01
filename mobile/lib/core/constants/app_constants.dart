class AppConstants {
  // App Info
  static const String appName = 'Makhzani';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://192.168.11.106:3000/api'; // Change to your backend IP
  static const String serverUrl = 'http://192.168.11.106:3000';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

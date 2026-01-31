class ApiEndpoints {
  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';

  // Merchant
  static const String merchantProfile = '/merchants/profile';
  static const String dashboardStats = '/merchants/dashboard-stats';

  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static String adjustStock(String id) => '/products/$id/adjust-stock';

  // Suppliers
  static const String suppliers = '/suppliers';
  static String supplierById(String id) => '/suppliers/$id';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String generatePdf(String id) => '/orders/$id/generate-pdf';
  static String downloadPdf(String id) => '/orders/$id/download-pdf';
  static String markSent(String id) => '/orders/$id/mark-sent';
}

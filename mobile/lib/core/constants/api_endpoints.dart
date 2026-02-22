class ApiEndpoints {
  // Auth
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';

  // Merchant
  static const String merchantProfile = '/merchants/profile';
  static const String dashboardStats = '/merchants/dashboard-stats';
  static const String merchantAvatar = '/merchants/avatar';
  static const String merchantFcmToken = '/merchants/fcm-token';

  // Products
  static const String products = '/products';
  static const String barcodeLookup = '/products/lookup';
  static const String productByBarcode = '/products/by-barcode';
  static String productById(String id) => '/products/$id';
  static String adjustStock(String id) => '/products/$id/adjust-stock';
  static String productImages(String id) => '/products/$id/images';
  static String productImage(String id, String imageId) => '/products/$id/images/$imageId';
  static String stockHistory(String id) => '/products/$id/stock-history';
  static const String exportCsv = '/products/export-csv';
  static const String csvTemplate = '/products/csv-template';
  static const String importCsv = '/products/import-csv';

  // Categories
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';
  static const String categoriesSeedDefaults = '/categories/seed-defaults';

  // Suppliers
  static const String suppliers = '/suppliers';
  static String supplierById(String id) => '/suppliers/$id';
  static String supplierAvatar(String id) => '/suppliers/$id/avatar';

  // Sales
  static const String sales = '/sales';
  static String saleById(String id) => '/sales/$id';
  static const String salesSummary = '/sales/summary';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String generatePdf(String id) => '/orders/$id/generate-pdf';
  static String downloadPdf(String id) => '/orders/$id/download-pdf';
  static String markSent(String id) => '/orders/$id/mark-sent';
  static String receiveOrder(String id) => '/orders/$id/receive';
  static const String orderSuggestions = '/orders/suggestions';
}

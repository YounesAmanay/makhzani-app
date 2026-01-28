import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static String? _cachedToken;

  static Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(AppConstants.tokenKey);
    return _cachedToken;
  }

  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _cachedToken != null) {
      headers['Authorization'] = 'Bearer $_cachedToken';
    }

    return headers;
  }

  // Authentication
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.sendOTP}'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({'phone_number': phoneNumber}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send OTP: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.verifyOTP}'),
      headers: _getHeaders(includeAuth: false),
      body: jsonEncode({
        'phone_number': phoneNumber,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _cachedToken = data['data']['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, _cachedToken!);
      return data;
    } else {
      throw Exception('Failed to verify OTP: ${response.body}');
    }
  }

  // Products
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? lowStock,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (lowStock == true) {
      queryParams['low_stock'] = 'true';
    }

    final uri = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch products: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required int currentStock,
    required int reorderThreshold,
    required String unit,
    double? price,
    String? barcode,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'current_stock': currentStock,
        'reorder_threshold': reorderThreshold,
        'unit': unit,
        if (price != null) 'price': price,
        if (barcode != null) 'barcode': barcode,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    int? currentStock,
    int? reorderThreshold,
    String? unit,
    double? price,
    String? barcode,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (currentStock != null) body['current_stock'] = currentStock;
    if (reorderThreshold != null) body['reorder_threshold'] = reorderThreshold;
    if (unit != null) body['unit'] = unit;
    if (price != null) body['price'] = price;
    if (barcode != null) body['barcode'] = barcode;

    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}/$productId'),
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> adjustStock(String productId, int adjustment) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}/$productId/adjust-stock'),
      headers: _getHeaders(),
      body: jsonEncode({
        'adjustment': adjustment,
        'reason': 'Manual adjustment from mobile app',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to adjust stock: ${response.body}');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.products}/$productId'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }

  // Dashboard stats
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.merchantProfile}/dashboard-stats'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch dashboard stats: ${response.body}');
    }
  }

  // Suppliers
  static Future<Map<String, dynamic>> getSuppliers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.suppliers}')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch suppliers: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createSupplier({
    required String name,
    String? businessName,
    required String phoneNumber,
    String? email,
    String? address,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.suppliers}'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        if (businessName != null) 'business_name': businessName,
        'phone_number': phoneNumber,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create supplier: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> updateSupplier({
    required String id,
    String? name,
    String? businessName,
    String? phoneNumber,
    String? email,
    String? address,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (businessName != null) body['business_name'] = businessName;
    if (phoneNumber != null) body['phone_number'] = phoneNumber;
    if (email != null) body['email'] = email;
    if (address != null) body['address'] = address;

    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.suppliers}/$id'),
      headers: _getHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update supplier: ${response.body}');
    }
  }

  static Future<void> deleteSupplier(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.suppliers}/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete supplier: ${response.body}');
    }
  }

  // Orders
  static Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final uri = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.orders}')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _getHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.orders}'),
      headers: _getHeaders(),
      body: jsonEncode({
        'supplier_id': supplierId,
        'items': items,
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> generateOrderPDF(String orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.orders}/$orderId/generate-pdf'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate PDF: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> markOrderAsSent(String orderId, String sentVia) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.orders}/$orderId/mark-sent'),
      headers: _getHeaders(),
      body: jsonEncode({'sent_via': sentVia}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to mark order as sent: ${response.body}');
    }
  }
}
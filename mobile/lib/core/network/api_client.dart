import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static String get baseUrl => AppConstants.baseUrl;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  // PATCH
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  // DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  // Download file
  Future<Response> download(
    String path,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.download(
      path,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// Interceptor for handling authentication tokens
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/OTP endpoints
    if (options.path.contains('/auth/send-otp') ||
        options.path.contains('/auth/verify-otp')) {
      return handler.next(options);
    }

    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry the original request
        final token = await _storage.read(key: 'access_token');
        err.requestOptions.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }

  /// Refresh token using current token in Authorization header
  /// Backend uses single-token system (same JWT for auth and refresh)
  Future<bool> _refreshToken() async {
    try {
      final currentToken = await _storage.read(key: 'access_token');
      if (currentToken == null) return false;

      final response = await Dio().post(
        '${ApiClient.baseUrl}${ApiEndpoints.refreshToken}',
        options: Options(
          headers: {'Authorization': 'Bearer $currentToken'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        // Backend returns single 'token' field
        await _storage.write(key: 'access_token', value: data['token']);
        return true;
      }
    } catch (e) {
      // Token refresh failed, user needs to login again
      await _storage.deleteAll();
    }
    return false;
  }
}

import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_result.dart';
import 'network_info.dart';

/// Base repository with common API call handling
/// Automatically handles errors, network checks, and parsing
abstract class BaseRepository {
  final ApiClient apiClient;
  final NetworkInfo networkInfo;

  BaseRepository(this.apiClient, this.networkInfo);

  /// Safely execute an API call with error handling
  Future<ApiResult<T>> safeApiCall<T>(
    Future<Response> Function() apiCall,
    T Function(dynamic data) parser,
  ) async {
    // Check network first
    if (!await networkInfo.isConnected) {
      return ApiResult.failure(ApiError.network());
    }

    try {
      final response = await apiCall();

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Success response
        final data = response.data;

        // Handle API response format: { success: true, data: {...} }
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          return ApiResult.success(parser(data['data']));
        }

        return ApiResult.success(parser(data));
      } else {
        // Error response
        return ApiResult.failure(
          ApiError.fromResponse(response.data, response.statusCode),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(ApiError.unknown(e.toString()));
    }
  }

  /// Handle Dio-specific errors
  ApiError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError.timeout();

      case DioExceptionType.connectionError:
        return ApiError.network();

      case DioExceptionType.badResponse:
        return ApiError.fromResponse(
          error.response?.data,
          error.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return const ApiError(message: 'Request was cancelled');

      default:
        return ApiError.unknown(error.message);
    }
  }
}

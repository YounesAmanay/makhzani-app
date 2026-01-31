import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_result.freezed.dart';

/// Generic API result wrapper using Freezed
/// Handles success and failure states cleanly
@freezed
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.failure(ApiError error) = Failure<T>;
}

/// API Error model
class ApiError {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? errors;

  const ApiError({
    required this.message,
    this.statusCode,
    this.code,
    this.errors,
  });

  factory ApiError.fromResponse(dynamic response, int? statusCode) {
    if (response is Map<String, dynamic>) {
      return ApiError(
        message: response['message'] ?? 'An error occurred',
        statusCode: statusCode,
        code: response['code'],
        errors: response['errors'],
      );
    }
    return ApiError(
      message: 'An error occurred',
      statusCode: statusCode,
    );
  }

  factory ApiError.network() => const ApiError(
        message: 'No internet connection',
        code: 'NETWORK_ERROR',
      );

  factory ApiError.timeout() => const ApiError(
        message: 'Request timed out',
        code: 'TIMEOUT',
      );

  factory ApiError.unknown([String? message]) => ApiError(
        message: message ?? 'An unexpected error occurred',
        code: 'UNKNOWN',
      );

  @override
  String toString() => 'ApiError(message: $message, code: $code, statusCode: $statusCode)';
}

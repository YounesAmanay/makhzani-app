/// URL Helper
///
/// Resolves image/file URLs that may be either:
/// - Absolute S3 URLs (new): https://makhzani-uploads.s3.eu-west-3.amazonaws.com/...
/// - Relative local paths (legacy): /uploads/products/uuid.jpg
///
/// Always use this instead of manually prepending AppConstants.serverUrl.
library;

import '../constants/app_constants.dart';

class UrlHelper {
  UrlHelper._();

  /// Returns a fully qualified URL ready for NetworkImage or Dio download.
  /// - If [url] already starts with 'http' → return as-is (S3 or external)
  /// - Otherwise → prepend server URL (legacy relative path)
  static String resolve(String url) {
    if (url.startsWith('http')) return url;
    return '${AppConstants.serverUrl}$url';
  }

  /// Null-safe variant — returns null if [url] is null or empty.
  static String? resolveNullable(String? url) {
    if (url == null || url.isEmpty) return null;
    return resolve(url);
  }
}

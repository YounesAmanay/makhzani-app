/// Preferences Provider
///
/// Riverpod provider for PreferencesService. Must be overridden at startup
/// in main() after SharedPreferences is initialized.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_service.dart';

/// Overridden in main() with the real SharedPreferences instance.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('preferencesServiceProvider must be overridden in main()');
});

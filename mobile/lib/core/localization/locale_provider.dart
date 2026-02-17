/// Locale Provider
///
/// Riverpod provider for app locale state with SharedPreferences persistence.
library;

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_provider.dart';
import '../services/preferences_service.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  final PreferencesService _prefs;

  LocaleNotifier(this._prefs) : super(_prefs.getLocale());

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setLocale(locale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.read(preferencesServiceProvider));
});

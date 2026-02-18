/// Preferences Service
///
/// Wraps SharedPreferences for reading and writing user preferences
/// (theme mode, language) that persist across app restarts.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // ── Theme ──────────────────────────────────────────────────────────────────

  ThemeMode getThemeMode() {
    final value = _prefs.getString(StorageKeys.themeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  // ── Locale ─────────────────────────────────────────────────────────────────

  Locale getLocale() {
    final code = _prefs.getString(StorageKeys.languageCode);
    if (code != null && code.isNotEmpty) {
      return Locale(code);
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(StorageKeys.languageCode, locale.languageCode);
  }
}

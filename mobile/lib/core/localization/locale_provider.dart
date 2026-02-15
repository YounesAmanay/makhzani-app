/// Locale Provider
///
/// Riverpod provider for app locale state.
library;

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current app locale
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

/// Theme Provider
///
/// Riverpod provider for theme mode state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current theme mode (light/dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

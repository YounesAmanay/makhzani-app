/// App Animation Constants
///
/// Standard animation durations and curves for consistent motion.
/// Use these instead of creating arbitrary durations.
library;

import 'package:flutter/material.dart';

class AppAnimations {
  // ============================================
  // DURATIONS
  // ============================================

  /// Fast animations - button states, opacity changes
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animations - most UI transitions
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animations - complex transitions, page changes
  static const Duration slow = Duration(milliseconds: 500);

  // ============================================
  // CURVES
  // ============================================

  /// Default curve for most animations
  static const Curve defaultCurve = Curves.easeInOut;

  /// Entrance animations
  static const Curve entranceCurve = Curves.easeOut;

  /// Exit animations
  static const Curve exitCurve = Curves.easeIn;

  /// Bounce effect for emphasis
  static const Curve bounceCurve = Curves.elasticOut;

  // ============================================
  // COMMON PATTERNS
  // ============================================

  /// Fade in widget
  static Widget fadeIn({
    required Widget child,
    required bool visible,
    Duration? duration,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration ?? fast,
      curve: defaultCurve,
      child: child,
    );
  }

  /// Scale animation
  static Widget scale({
    required Widget child,
    required bool visible,
    Duration? duration,
  }) {
    return AnimatedScale(
      scale: visible ? 1.0 : 0.8,
      duration: duration ?? fast,
      curve: defaultCurve,
      child: child,
    );
  }
}

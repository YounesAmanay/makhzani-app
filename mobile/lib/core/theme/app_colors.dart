import 'package:flutter/material.dart';

/// Makhzani Color Palette
///
/// Design Philosophy: Shopify-inspired, comfortable grey-based palette
/// - Grey backgrounds for reduced eye strain
/// - Pure white cards for content focus
/// - Single accent color (green) for actions
/// - Consistent grey scale (all derived from same base)

class AppColors {
  // ============================================
  // BRAND COLORS
  // ============================================

  /// Primary action color - Moroccan-inspired green
  static const Color primary = Color(0xFF008060);      // Shopify green
  static const Color primaryHover = Color(0xFF006E52); // Darker for hover/pressed
  static const Color primaryLight = Color(0xFFE3F1ED); // Subtle green tint for backgrounds
  static const Color primaryMuted = Color(0xFFA4D4AE); // Muted green for secondary elements

  // ============================================
  // GREY SCALE (Harmonized - Single Family)
  // Based on neutral grey with slight warm undertone
  // ============================================

  /// Pure white - Cards, modals, input backgrounds
  static const Color white = Color(0xFFFFFFFF);

  /// App background - Comfortable grey
  static const Color background = Color(0xFFF6F6F7);

  /// Secondary background - Slightly darker sections
  static const Color backgroundSecondary = Color(0xFFF1F1F1);

  /// Surface - Cards, elevated elements (pure white)
  static const Color surface = Color(0xFFFFFFFF);

  /// Subtle surface - Hover states on cards
  static const Color surfaceHover = Color(0xFFFAFAFB);

  /// Pressed surface state
  static const Color surfacePressed = Color(0xFFF4F4F5);

  // ============================================
  // TEXT COLORS (Consistent grey scale)
  // ============================================

  /// Primary text - Headings, important content
  static const Color textPrimary = Color(0xFF202223);

  /// Secondary text - Body text, descriptions
  static const Color textSecondary = Color(0xFF616161);

  /// Tertiary text - Labels, captions, hints
  static const Color textTertiary = Color(0xFF8C8C8C);

  /// Disabled text
  static const Color textDisabled = Color(0xFFB5B5B5);

  /// Placeholder text in inputs
  static const Color textPlaceholder = Color(0xFFA1A1A1);

  // ============================================
  // BORDERS & DIVIDERS (Subtle, consistent)
  // ============================================

  /// Default border - Cards, inputs
  static const Color border = Color(0xFFE1E3E5);

  /// Focused/hover border
  static const Color borderHover = Color(0xFFC9CCCF);

  /// Strong border - Emphasis
  static const Color borderStrong = Color(0xFF8C9196);

  /// Divider - Separating content sections
  static const Color divider = Color(0xFFEBEBEB);

  // ============================================
  // SEMANTIC COLORS (Status)
  // ============================================

  /// Success - Confirmations, positive actions
  static const Color success = Color(0xFF008060);
  static const Color successBackground = Color(0xFFAEE9D1);

  /// Error - Validation errors, destructive actions
  static const Color error = Color(0xFFD72C0D);
  static const Color errorBackground = Color(0xFFFED3D1);

  /// Warning - Caution states
  static const Color warning = Color(0xFFB98900);
  static const Color warningBackground = Color(0xFFFFEA8A);

  /// Info - Informational messages
  static const Color info = Color(0xFF2C6ECB);
  static const Color infoBackground = Color(0xFFA4CAFE);

  // ============================================
  // INTERACTIVE STATES
  // ============================================

  /// Overlay for modals/dialogs
  static const Color overlay = Color(0x52000000);

  /// Shimmer/skeleton loading
  static const Color shimmerBase = Color(0xFFEBEBEB);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  /// Icon colors
  static const Color iconPrimary = Color(0xFF5C5F62);
  static const Color iconSecondary = Color(0xFF8C9196);
  static const Color iconDisabled = Color(0xFFBABEC3);

  // ============================================
  // SPECIFIC USE CASES
  // ============================================

  /// Input field background
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBackgroundDisabled = Color(0xFFF6F6F7);

  /// Badge/tag backgrounds
  static const Color badgeNeutral = Color(0xFFE4E5E7);
  static const Color badgeNeutralText = Color(0xFF202223);
}

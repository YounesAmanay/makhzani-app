/// App Loading Widget
///
/// Standard loading indicator for the app.
/// Use this instead of creating custom loading states.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Full screen loading - use when entire screen is loading
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Inline loading - use inside cards or sections
class AppLoadingIndicator extends StatelessWidget {
  final double size;

  const AppLoadingIndicator({
    super.key,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.primary,
      ),
    );
  }
}

/// Button loading - use inside buttons
class AppButtonLoading extends StatelessWidget {
  final Color color;

  const AppButtonLoading({
    super.key,
    this.color = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    );
  }
}

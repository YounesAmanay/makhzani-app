/// App Error State Widget
///
/// Standard error state for screens and sections.
/// Use when an error occurs during data fetching.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/localization/l10n_extension.dart';

class AppErrorState extends StatelessWidget {
  /// Error message to display (use l10n)
  final String message;

  /// Callback when retry button is pressed
  final VoidCallback onRetry;

  /// Optional custom title (defaults to l10n error_generic)
  final String? title;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAlertCircle,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              title ?? context.l10n.error_generic,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginLarge),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowReloadHorizontal,
                size: 18,
                color: AppColors.primary,
              ),
              label: Text(context.l10n.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}


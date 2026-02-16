/// Reusable Filter Chip
///
/// Toggle chip for filter states. Follows Material 3 filter chip design.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;
  final bool showClose;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.showClose = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isActive
          ? AppColors.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isActive
                      ? AppColors.white
                      : theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isActive
                      ? AppColors.white
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (isActive && showClose) ...[
                const SizedBox(width: AppDimensions.marginSmall),
                Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

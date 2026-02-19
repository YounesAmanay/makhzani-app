/// Stats Card Widget
///
/// Display a single statistic with icon, value, and label.
/// Used in dashboard and summary screens.
library;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/theme/app_dimensions.dart';

class StatsCard extends StatelessWidget {
  /// Hugeicon icon data
  final List<List<dynamic>> icon;

  /// Label text (use l10n)
  final String title;

  /// Value to display (formatted string)
  final String value;

  /// Icon color (tints both icon and its background container)
  final Color? iconColor;

  /// Optional tap callback
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tinted icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.marginMedium),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: AppDimensions.marginXSmall),
              Text(
                title,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

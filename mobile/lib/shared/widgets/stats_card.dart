/// Stats Card Widget
///
/// Display a single statistic with icon, value, and label.
/// Used in dashboard and summary screens.
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class StatsCard extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Label text (use l10n)
  final String title;

  /// Value to display (formatted string)
  final String value;

  /// Optional custom icon color
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor ?? AppColors.iconSecondary,
                size: AppDimensions.iconMedium,
              ),
              const SizedBox(height: AppDimensions.marginLarge),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: AppDimensions.marginXSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
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

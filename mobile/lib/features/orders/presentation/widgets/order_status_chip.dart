/// Order Status Chip Widget
///
/// Displays order status with color-coded badge.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/order_status.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusData(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: AppDimensions.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (String, Color) _getStatusData(BuildContext context) {
    if (status.isDraft) {
      return (context.l10n.orders_statusDraft, AppColors.textSecondary);
    }
    if (status.isGenerated) {
      return (context.l10n.orders_statusGenerated, AppColors.info);
    }
    if (status.isSent) {
      return (context.l10n.orders_statusSent, AppColors.success);
    }
    return (context.l10n.orders_statusDraft, AppColors.textSecondary);
  }
}

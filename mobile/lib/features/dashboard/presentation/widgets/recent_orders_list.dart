/// Recent Orders List Widget
///
/// Displays a list of recent purchase orders.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/recent_order.dart';

class RecentOrdersList extends StatelessWidget {
  final List<RecentOrder> orders;
  final VoidCallback? onSeeAll;

  const RecentOrdersList({
    super.key,
    required this.orders,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.dashboard_noOrders,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ...orders.take(5).map((order) => _RecentOrderTile(order: order)),
          if (orders.length > 5)
            InkWell(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.dashboard_seeAllOrders,
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final RecentOrder order;

  const _RecentOrderTile({required this.order});

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return context.l10n.common_today;
    if (diff.inDays == 1) return context.l10n.common_yesterday;
    if (diff.inDays < 7) return context.l10n.common_daysAgo(diff.inDays);

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  order.supplierName ?? context.l10n.suppliers_unknown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(context, order.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(width: 12),
          // PDF status
          Icon(
            Icons.picture_as_pdf,
            size: 18,
            color: order.pdfGenerated ? AppColors.primary : AppColors.textDisabled,
          ),
          const SizedBox(width: 8),
          // Sent status
          Icon(
            order.sent ? Icons.check_circle : Icons.schedule,
            size: 18,
            color: order.sent ? AppColors.success : AppColors.textDisabled,
          ),
        ],
      ),
    );
  }
}

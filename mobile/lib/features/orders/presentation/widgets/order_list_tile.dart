/// Order List Tile Widget
///
/// Displays a single order in a list with status, supplier, and summary.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import 'order_status_chip.dart';

class OrderListTile extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderListTile({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status accent bar
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),

                  // Content
                  Expanded(child: _buildContent(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Order number + status chip
        Row(
          children: [
            Expanded(
              child: Text(
                order.orderNumber,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            OrderStatusChip(status: order.status),
          ],
        ),
        const SizedBox(height: AppDimensions.marginXSmall),

        // Supplier name
        Text(
          order.supplier.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppDimensions.marginSmall),

        // Summary: items count + total value + date
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    '${order.totalItems} ${order.totalItems == 1 ? context.l10n.orders_item : context.l10n.orders_items}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                  if (order.totalValue > 0) ...[
                    Text(
                      ' • ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                    Text(
                      '${order.totalValue.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.marginSmall),
            Text(
              _formatRelativeDate(context, order.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    if (status.isSent) return AppColors.success;
    return AppColors.warning;
  }

  String _formatRelativeDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return context.l10n.common_minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return context.l10n.common_hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return context.l10n.common_yesterday;
    } else if (difference.inDays < 7) {
      return context.l10n.common_daysAgo(difference.inDays);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

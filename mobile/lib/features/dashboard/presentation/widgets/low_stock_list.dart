/// Low Stock List Widget
///
/// Displays a list of products below reorder threshold.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/low_stock_item.dart';

class LowStockList extends StatelessWidget {
  final List<LowStockItem> items;
  final VoidCallback? onSeeAll;
  final VoidCallback? onOrderSuggestions;

  const LowStockList({
    super.key,
    required this.items,
    this.onSeeAll,
    this.onOrderSuggestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
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
              Icons.check_circle_outline,
              color: AppColors.success,
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.dashboard_allStocked,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      );
    }

    final visibleItems = items.take(5).toList();
    final hasFooter = onOrderSuggestions != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ...visibleItems.indexed.map((e) => _LowStockItemTile(
                item: e.$2,
                isLast: e.$1 == visibleItems.length - 1 && !hasFooter,
              )),

          // "Order suggestions →" footer
          if (hasFooter)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppDimensions.radiusMedium),
              ),
              child: InkWell(
                onTap: onOrderSuggestions,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: const BoxDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.orders_reorderSuggestions,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.success),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LowStockItemTile extends StatelessWidget {
  final LowStockItem item;
  final bool isLast;

  const _LowStockItemTile({required this.item, this.isLast = false});

  Color get _statusColor {
    if (item.currentStock == 0) return AppColors.error;
    if (item.shortage > 5) return AppColors.warning;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        '/products/detail',
        arguments: item.id,
      ),
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusMedium))
          : BorderRadius.zero,
      child: Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${item.currentStock}/${item.reorderThreshold} ${item.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-${item.shortage}',
              style: theme.textTheme.bodySmall?.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

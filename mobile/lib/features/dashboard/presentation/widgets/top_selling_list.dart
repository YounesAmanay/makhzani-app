import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/top_selling_product.dart';

class TopSellingList extends StatelessWidget {
  final List<TopSellingProduct> items;
  final void Function(String productId)? onTap;

  const TopSellingList({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Center(
            child: Text(
              context.l10n.dashboard_noSalesThisMonth,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final product = entry.value;
            final isFirst = rank == 1;
            final isLast = rank == items.length;

            return Column(
              children: [
                InkWell(
                  onTap: onTap != null ? () => onTap!(product.productId) : null,
                  borderRadius: BorderRadius.vertical(
                    top: isFirst
                        ? Radius.circular(AppDimensions.radiusMedium)
                        : Radius.zero,
                    bottom: isLast
                        ? Radius.circular(AppDimensions.radiusMedium)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium,
                      vertical: AppDimensions.paddingSmall,
                    ),
                    child: Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: rank == 1
                                ? AppColors.warning.withValues(alpha: 0.15)
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Center(
                            child: Text(
                              '#$rank',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: rank == 1
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.marginSmall),
                        // Product name + qty
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${product.totalSold.toStringAsFixed(product.totalSold % 1 == 0 ? 0 : 1)} ${product.unit} ${context.l10n.dashboard_sold}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Revenue
                        Text(
                          '${product.totalRevenue.toStringAsFixed(0)} ${context.l10n.currency_mad}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, indent: AppDimensions.paddingMedium),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

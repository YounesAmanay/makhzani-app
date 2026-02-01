/// Product List Tile Widget
///
/// Displays a single product in a list with stock status indicator.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Stock status indicator
                _buildStockIndicator(),
                const SizedBox(width: AppDimensions.marginSmall),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      _buildStockChip(context),
                    ],
                  ),
                ),

                const SizedBox(width: AppDimensions.marginSmall),

                // Stock count and unit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.currentStock.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getStockColor(),
                          ),
                    ),
                    Text(
                      product.unit,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),

                const SizedBox(width: AppDimensions.marginXSmall),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.iconSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockIndicator() {
    return Container(
      width: 4,
      decoration: BoxDecoration(
        color: _getStockColor(),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStockChip(BuildContext context) {
    final (label, bgColor, textColor) = _getStockChipData(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Color _getStockColor() {
    if (product.isOutOfStock) return AppColors.error;
    if (product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  (String, Color, Color) _getStockChipData(BuildContext context) {
    if (product.isOutOfStock) {
      return (context.l10n.products_outOfStock, AppColors.errorBackground, AppColors.error);
    }
    if (product.isLowStock) {
      return (context.l10n.products_lowStockWarning, AppColors.warningBackground, AppColors.warning);
    }
    return (context.l10n.products_inStock, AppColors.successBackground, AppColors.success);
  }
}

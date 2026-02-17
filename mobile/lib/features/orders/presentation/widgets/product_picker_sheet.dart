/// Product Picker Sheet
///
/// Bottom sheet for selecting a product to add to the order.
library;

import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/domain/entities/product.dart';

class ProductPickerSheet extends StatefulWidget {
  final List<Product> products;
  final List<String> excludedProductIds;
  final Function(Product) onSelect;

  const ProductPickerSheet({
    super.key,
    required this.products,
    required this.excludedProductIds,
    required this.onSelect,
  });

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();

  static Future<Product?> show({
    required BuildContext context,
    required List<Product> products,
    required List<String> excludedProductIds,
  }) {
    return showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => ProductPickerSheet(
        products: products,
        excludedProductIds: excludedProductIds,
        onSelect: (product) => Navigator.of(context).pop(product),
      ),
    );
  }
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  String _searchQuery = '';

  List<Product> get _filteredProducts {
    final available = widget.products
        .where((p) => !widget.excludedProductIds.contains(p.id))
        .toList();

    if (_searchQuery.isEmpty) return available;

    final query = _searchQuery.toLowerCase();
    return available.where((p) {
      return p.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filteredProducts;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.orders_selectProduct,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: context.l10n.common_cancel,
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: context.l10n.common_search,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),

            // Product list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.iconSecondary,
                            ),
                            const SizedBox(height: AppDimensions.marginMedium),
                            Text(
                              _searchQuery.isEmpty
                                  ? context.l10n.orders_noProductsAvailable
                                  : context.l10n.products_noResults,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                        vertical: AppDimensions.paddingSmall,
                      ),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return _buildProductTile(product);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductTile(Product product) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: InkWell(
        onTap: () => widget.onSelect(product),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginXSmall),
                    Row(
                      children: [
                        Text(
                          '${context.l10n.products_currentStock}: ${product.currentStock} ${product.unit}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (product.price != null) ...[
                          Text(
                            ' • ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            '${product.price!.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.marginSmall),
              Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

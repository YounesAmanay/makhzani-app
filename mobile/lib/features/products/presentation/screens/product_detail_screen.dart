/// Product Detail Screen
///
/// Displays product details with stock adjustment and edit/delete actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product.dart';
import '../providers/product_form_provider.dart';
import '../widgets/stock_adjustment_dialog.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    final product = await ref
        .read(productFormProvider.notifier)
        .getProductById(widget.productId);

    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? context.l10n.products),
        actions: [
          if (_product != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: context.l10n.common_edit,
              onPressed: () async {
                await Navigator.of(context).pushNamed(
                  '/products/edit',
                  arguments: widget.productId,
                );
                _loadProduct();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.common_delete,
              onPressed: () => _showDeleteDialog(),
            ),
          ],
        ],
      ),
      body: _buildBody(formState),
    );
  }

  Widget _buildBody(ProductFormState formState) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_product == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(context.l10n.error_generic),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProduct,
              child: Text(context.l10n.common_retry),
            ),
          ],
        ),
      );
    }

    final product = _product!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stock Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                children: [
                  Text(
                    context.l10n.products_currentStock,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        product.currentStock.toString(),
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getStockColor(product),
                                ),
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        product.unit,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  _buildStockStatusChip(product),
                  const SizedBox(height: AppDimensions.marginLarge),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: formState.status == ProductFormStatus.loading
                          ? null
                          : () => _showStockAdjustmentDialog(product),
                      icon: const Icon(Icons.tune),
                      label: Text(context.l10n.products_adjustStock),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.marginMedium),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.products_details,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  _buildDetailRow(context.l10n.products_name, product.name),
                  _buildDetailRow(
                      context.l10n.products_reorderThreshold, '${product.reorderThreshold} ${product.unit}'),
                  if (product.barcode != null)
                    _buildDetailRow(context.l10n.products_barcode, product.barcode!),
                  if (product.price != null)
                    _buildDetailRow(
                        context.l10n.products_price, '${product.price!.toStringAsFixed(2)} ${context.l10n.currency_mad}'),
                  _buildDetailRow(
                    context.l10n.products_unit,
                    product.unit,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  Widget _buildStockStatusChip(Product product) {
    final (label, bgColor, textColor) = _getStockStatusData(product);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Color _getStockColor(Product product) {
    if (product.isOutOfStock) return AppColors.error;
    if (product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  (String, Color, Color) _getStockStatusData(Product product) {
    if (product.isOutOfStock) {
      return (context.l10n.products_outOfStock, AppColors.errorBackground, AppColors.error);
    }
    if (product.isLowStock) {
      return (context.l10n.products_lowStockWarning, AppColors.warningBackground, AppColors.warning);
    }
    return (context.l10n.products_inStock, AppColors.successBackground, AppColors.success);
  }

  void _showStockAdjustmentDialog(Product product) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => StockAdjustmentDialog(
        product: product,
        onSubmit: (adjustment, reason) async {
          final success =
              await ref.read(productFormProvider.notifier).adjustStock(
                    id: product.id,
                    adjustment: adjustment,
                    reason: reason,
                  );

          if (success && mounted) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(context.l10n.products_stockAdjusted),
                backgroundColor: AppColors.success,
              ),
            );
            _loadProduct();
          }
        },
      ),
    );
  }

  void _showDeleteDialog() {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.confirm_deleteTitle),
        content: Text(context.l10n.products_deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.common_cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await ref
                  .read(productFormProvider.notifier)
                  .deleteProduct(widget.productId);

              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.products_deleted),
                    backgroundColor: AppColors.success,
                  ),
                );
                navigator.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(context.l10n.common_delete),
          ),
        ],
      ),
    );
  }
}

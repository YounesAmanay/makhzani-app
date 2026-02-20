/// Product Detail Screen
///
/// Displays product details with stock adjustment and edit/delete actions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../domain/entities/product.dart';
import '../providers/product_form_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/stock_adjustment_sheet.dart';

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
  bool _isDeleting = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    // Only show spinner on first load
    setState(() => _isLoading = _product == null);

    try {
      final repository = ref.read(productsRepositoryProvider);
      final product = await repository.getProductById(widget.productId);

      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // DO NOT watch productFormProvider here - it causes rebuild loop
    // Only read it when performing actions (delete, adjust)

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
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: context.l10n.common_delete,
              onPressed: _isDeleting ? null : () => _showDeleteDialog(),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadProduct,
                  child: _buildContent(_product!),
                ),
    );
  }

  Widget _buildErrorState() {
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

  Widget _buildContent(Product product) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                    style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
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
                        style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getStockColor(product),
                            ),
                      ),
                      const SizedBox(width: AppDimensions.marginSmall),
                      Text(
                        product.unit,
                        style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
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
                      onPressed: () => _showStockAdjustmentDialog(product),
                      icon: const Icon(Icons.tune),
                      label: Text(context.l10n.products_adjustStock),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.marginMedium),

          // Images Card
          _buildImagesCard(product),

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
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  _buildDetailRow(context.l10n.products_name, product.name),
                  _buildDetailRow(
                    context.l10n.products_reorderThreshold,
                    '${product.reorderThreshold} ${product.unit}',
                  ),
                  if (product.barcode != null)
                    _buildDetailRow(
                      context.l10n.products_barcode,
                      product.barcode!,
                    ),
                  if (product.price != null)
                    _buildDetailRow(
                      context.l10n.products_price,
                      '${product.price!.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                    ),
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

  Widget _buildImagesCard(Product product) {
    final theme = Theme.of(context);
    final images = product.images;
    final canAddMore = images.length < 5;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.products_photos,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (canAddMore)
                  TextButton.icon(
                    onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                    icon: _isUploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: Text(context.l10n.products_addPhoto),
                  )
                else
                  Text(
                    context.l10n.products_maxPhotos,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.marginSmall),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppDimensions.marginSmall),
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMedium,
                          ),
                          child: Image.network(
                            AppConstants.serverUrl + image.imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _confirmDeleteImage(
                              product.id,
                              image.id,
                            ),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null || !mounted) return;

    setState(() => _isUploadingImage = true);

    try {
      final repository = ref.read(productsRepositoryProvider);
      await repository.uploadProductImage(widget.productId, image.path);
      await _loadProduct();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_generic),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _confirmDeleteImage(String productId, String imageId) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.products_deletePhoto,
      message: context.l10n.confirm_delete,
      confirmLabel: context.l10n.common_delete,
      isDestructive: true,
      icon: HugeIcons.strokeRoundedDelete01,
    );
    if (!confirmed || !mounted) return;

    try {
      final repository = ref.read(productsRepositoryProvider);
      await repository.deleteProductImage(productId, imageId);
      await _loadProduct();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_generic),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    final theme = Theme.of(context);

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
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
      return (
        context.l10n.products_outOfStock,
        AppColors.errorBackground,
        AppColors.error
      );
    }
    if (product.isLowStock) {
      return (
        context.l10n.products_lowStockWarning,
        AppColors.warningBackground,
        AppColors.warning
      );
    }
    return (
      context.l10n.products_inStock,
      AppColors.successBackground,
      AppColors.success
    );
  }

  void _showStockAdjustmentDialog(Product product) {
    StockAdjustmentSheet.show(
      context: context,
      product: product,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.products_stockAdjusted),
            backgroundColor: AppColors.success,
          ),
        );
        _loadProduct();
        ref.read(productsProvider.notifier).refresh();
      },
    );
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.confirm_deleteTitle,
      message: context.l10n.products_deleteConfirm,
      confirmLabel: context.l10n.common_delete,
      isDestructive: true,
      icon: HugeIcons.strokeRoundedDelete01,
    );

    if (!confirmed || !mounted) return;

    setState(() => _isDeleting = true);

    final success = await ref
        .read(productFormProvider.notifier)
        .deleteProduct(widget.productId);

    if (mounted) {
      setState(() => _isDeleting = false);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.products_deleted),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

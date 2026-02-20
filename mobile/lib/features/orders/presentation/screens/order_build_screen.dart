/// Order Build Screen — Step 2 of 3
///
/// Product search + inline quantity stepper.
/// Running total in sticky bottom bar → Review Order.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../providers/order_draft_provider.dart';
import 'order_review_screen.dart';

class OrderBuildScreen extends ConsumerStatefulWidget {
  const OrderBuildScreen({super.key});

  @override
  ConsumerState<OrderBuildScreen> createState() => _OrderBuildScreenState();
}

class _OrderBuildScreenState extends ConsumerState<OrderBuildScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productsProvider.notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _callSupplier(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider);
    final productsState = ref.watch(productsProvider);

    final allProducts = productsState.products;
    final filtered = _query.isEmpty
        ? allProducts
        : allProducts
            .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.orders_buildOrderTitle(draft.supplierName ?? ''),
        ),
      ),
      bottomNavigationBar:
          draft.canReview ? _buildBottomBar(draft) : null,
      body: Column(
        children: [
          // Supplier header
          _buildSupplierHeader(draft),

          // Product search
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.orders_searchProducts,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: context.l10n.common_clear,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),

          // Product list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.products_noResults,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingMedium,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final inOrder = draft.hasProduct(product.id);
                      final item = inOrder
                          ? draft.items
                              .firstWhere((i) => i.productId == product.id)
                          : null;
                      return _ProductRow(
                        product: product,
                        inOrder: inOrder,
                        quantity: item?.quantity ?? 1.0,
                        unitPrice: item?.unitPrice ?? product.price ?? 0.0,
                        onAdd: () => ref
                            .read(orderDraftProvider.notifier)
                            .addProduct(product),
                        onRemove: () => ref
                            .read(orderDraftProvider.notifier)
                            .removeProduct(product.id),
                        onQtyChanged: (qty) => ref
                            .read(orderDraftProvider.notifier)
                            .updateQuantity(product.id, qty),
                        onPriceChanged: (price) => ref
                            .read(orderDraftProvider.notifier)
                            .updatePrice(product.id, price),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierHeader(OrderDraftState draft) {
    final theme = Theme.of(context);
    final initials =
        draft.supplierName?.isNotEmpty == true ? draft.supplierName![0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          draft.supplierAvatarUrl != null
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    AppConstants.serverUrl + draft.supplierAvatarUrl!,
                  ),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    initials,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          const SizedBox(width: AppDimensions.marginMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.supplierName ?? '',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (draft.supplierPhone != null)
                  Text(
                    draft.supplierPhone!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          if (draft.supplierPhone != null)
            IconButton(
              icon: const Icon(Icons.phone_outlined),
              color: AppColors.primary,
              tooltip: context.l10n.orders_callSupplier,
              onPressed: () => _callSupplier(draft.supplierPhone!),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(OrderDraftState draft) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  context.l10n.orders_itemsSummary(
                    draft.itemCount,
                    draft.totalValue.toStringAsFixed(2),
                  ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              IntrinsicWidth(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const OrderReviewScreen()),
                    );
                  },
                  child: Text(context.l10n.orders_reviewOrder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatefulWidget {
  final Product product;
  final bool inOrder;
  final double quantity;
  final double unitPrice;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onPriceChanged;

  const _ProductRow({
    required this.product,
    required this.inOrder,
    required this.quantity,
    required this.unitPrice,
    required this.onAdd,
    required this.onRemove,
    required this.onQtyChanged,
    required this.onPriceChanged,
  });

  @override
  State<_ProductRow> createState() => _ProductRowState();
}

class _ProductRowState extends State<_ProductRow> {
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.unitPrice > 0 ? widget.unitPrice.toStringAsFixed(2) : '',
    );
  }

  @override
  void didUpdateWidget(_ProductRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync price field only when not focused
    if (oldWidget.unitPrice != widget.unitPrice &&
        !_priceController.selection.isValid) {
      _priceController.text =
          widget.unitPrice > 0 ? widget.unitPrice.toStringAsFixed(2) : '';
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Color _stockColor() {
    if (widget.product.isOutOfStock) return AppColors.error;
    if (widget.product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  (String, Color, Color) _stockChipData(BuildContext context) {
    if (widget.product.isOutOfStock) {
      return (
        context.l10n.orders_outOfStock,
        AppColors.error.withValues(alpha: 0.1),
        AppColors.error,
      );
    }
    if (widget.product.isLowStock) {
      return (
        context.l10n.orders_stockLabel(
            widget.product.currentStock, widget.product.unit),
        AppColors.warning.withValues(alpha: 0.1),
        AppColors.warning,
      );
    }
    return (
      context.l10n.orders_stockLabel(
          widget.product.currentStock, widget.product.unit),
      AppColors.success.withValues(alpha: 0.1),
      AppColors.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (chipLabel, chipBg, chipText) = _stockChipData(context);
    final accentColor = _stockColor();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: widget.inOrder ? null : widget.onAdd,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: widget.inOrder
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                // Stock accent bar — full card height via positioned left strip
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusMedium),
                        bottomLeft: Radius.circular(AppDimensions.radiusMedium),
                      ),
                    ),
                  ),
                ),

                // Content with left padding for the accent bar
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppDimensions.paddingMedium + 3,
                    AppDimensions.paddingMedium,
                    AppDimensions.paddingMedium,
                    AppDimensions.paddingMedium,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name row + stock chip + action button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.marginSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: chipBg,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusSmall),
                              ),
                              child: Text(
                                chipLabel,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: chipText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.marginSmall),
                            // Add / Remove action
                            if (!widget.inOrder)
                              SizedBox(
                                height: 32,
                                child: TextButton(
                                  onPressed: widget.onAdd,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimensions.paddingSmall),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(context.l10n.orders_addToOrder),
                                ),
                              )
                            else
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  color: AppColors.error,
                                  tooltip: context.l10n.orders_remove,
                                  onPressed: widget.onRemove,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.marginXSmall),

                        // Subtitle: barcode or unit
                        Text(
                          widget.product.barcode?.isNotEmpty == true
                              ? widget.product.barcode!
                              : widget.product.unit,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),

                        // Footer: stock count + price
                        Row(
                          children: [
                            Text(
                              '${widget.product.currentStock} ${widget.product.unit}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            if (widget.product.price != null &&
                                widget.product.price! > 0) ...[
                              Text(
                                ' • ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              Text(
                                '${widget.product.price!.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Inline stepper + price field (only when added)
                        if (widget.inOrder) ...[
                          const SizedBox(height: AppDimensions.marginMedium),
                          Row(
                            children: [
                              _QtyStepper(
                                quantity: widget.quantity,
                                unit: widget.product.unit,
                                onChanged: widget.onQtyChanged,
                              ),
                              const SizedBox(width: AppDimensions.marginMedium),
                              Expanded(
                                child: TextField(
                                  controller: _priceController,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.orders_unitPrice,
                                    suffixText: context.l10n.currency_mad,
                                    isDense: true,
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}')),
                                  ],
                                  onChanged: (v) {
                                    final price = double.tryParse(v) ?? 0.0;
                                    widget.onPriceChanged(price);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final double quantity;
  final String unit;
  final ValueChanged<double> onChanged;

  const _QtyStepper({
    required this.quantity,
    required this.unit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall),
          child: Text(
            '${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 1)} $unit',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onPressed: () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: onPressed == null
                ? AppColors.border
                : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onPressed == null ? AppColors.textSecondary : AppColors.primary,
        ),
      ),
    );
  }
}

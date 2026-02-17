/// Order Item Row Widget
///
/// Single product row in the order form with quantity, price, and total.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../products/domain/entities/product.dart';
import '../providers/order_form_provider.dart';
import 'product_picker_sheet.dart';

class OrderItemRow extends StatefulWidget {
  final int index;
  final OrderItemInput item;
  final List<Product> products;
  final List<String> excludedProductIds;
  final Function(OrderItemInput) onChanged;
  final VoidCallback onRemove;

  const OrderItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.products,
    required this.excludedProductIds,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<OrderItemRow> createState() => _OrderItemRowState();
}

class _OrderItemRowState extends State<OrderItemRow> {
  late TextEditingController _quantityController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product selector + Remove button
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectProduct,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSmall,
                        vertical: AppDimensions.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.productName ??
                                  context.l10n.orders_selectProduct,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.item.productName != null
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.iconSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  tooltip: context.l10n.orders_remove,
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),

            // Quantity + Unit Price + Total
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: context.l10n.orders_quantity,
                      suffix: widget.item.productUnit != null
                          ? Text(widget.item.productUnit!)
                          : null,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$'),
                      ),
                    ],
                    onChanged: (value) {
                      final qty = double.tryParse(value);
                      widget.onChanged(widget.item.copyWith(quantity: qty));
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),

                // Unit Price
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: context.l10n.orders_unitPrice,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*$'),
                      ),
                    ],
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      widget.onChanged(widget.item.copyWith(unitPrice: price));
                    },
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),

                // Total (read-only)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.orders_itemTotal,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.marginSmall),
                      Text(
                        '${widget.item.total.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProduct() async {
    final product = await ProductPickerSheet.show(
      context: context,
      products: widget.products,
      excludedProductIds: widget.excludedProductIds,
    );

    if (product != null) {
      _priceController.text = product.price?.toString() ?? '';
      widget.onChanged(
        widget.item.copyWith(
          productId: product.id,
          productName: product.name,
          productUnit: product.unit,
          unitPrice: product.price,
        ),
      );
    }
  }
}

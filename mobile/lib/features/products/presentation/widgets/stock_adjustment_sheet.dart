/// Stock Adjustment Sheet
///
/// Bottom sheet for adjusting product stock with signed number input.
/// Use positive numbers to add stock, negative to remove.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product.dart';

class StockAdjustmentSheet extends StatefulWidget {
  final Product product;
  final Function(int adjustment, String? reason) onSubmit;

  const StockAdjustmentSheet({
    super.key,
    required this.product,
    required this.onSubmit,
  });

  /// Shows the stock adjustment bottom sheet
  static void show({
    required BuildContext context,
    required Product product,
    required Function(int adjustment, String? reason) onSubmit,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => StockAdjustmentSheet(
        product: product,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<StockAdjustmentSheet> createState() => _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends State<StockAdjustmentSheet> {
  final _adjustmentController = TextEditingController();
  final _reasonController = TextEditingController();

  int get _adjustment {
    final text = _adjustmentController.text.trim();
    if (text.isEmpty) return 0;
    return int.tryParse(text) ?? 0;
  }

  int get _newStock => widget.product.currentStock + _adjustment;

  @override
  void dispose() {
    _adjustmentController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginLarge),

                // Title
                Text(
                  context.l10n.products_adjustStock,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),

                // Product info
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.product.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    Text(
                      '${widget.product.currentStock} ${widget.product.unit}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Adjustment field with signed input
                TextField(
                  controller: _adjustmentController,
                  keyboardType: const TextInputType.numberWithOptions(signed: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.products_adjustment,
                    hintText: context.l10n.products_adjustmentHint,
                    suffixText: widget.product.unit,
                    helperText: context.l10n.products_adjustmentHelper,
                    helperMaxLines: 2,
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: AppDimensions.marginMedium),

                // New stock preview
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${context.l10n.products_newStock}:',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '$_newStock ${widget.product.unit}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _newStock < 0 ? AppColors.error : null,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_newStock < 0) ...[
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    context.l10n.products_stockNegativeError,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.marginMedium),

                // Reason field
                TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: context.l10n.products_reason,
                  ),
                  onSubmitted: (_) {
                    if (_canSubmit()) _handleSubmit();
                  },
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Submit button
                SizedBox(
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: _canSubmit() ? _handleSubmit : null,
                    child: Text(context.l10n.products_adjustStock),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canSubmit() {
    return _adjustment != 0 && _newStock >= 0;
  }

  void _handleSubmit() {
    final reason = _reasonController.text.trim();
    widget.onSubmit(
      _adjustment,
      reason.isEmpty ? null : reason,
    );
    Navigator.of(context).pop();
  }
}

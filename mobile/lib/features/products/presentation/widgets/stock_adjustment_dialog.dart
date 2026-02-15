/// Stock Adjustment Dialog
///
/// Dialog for adjusting product stock with reason field.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final Product product;
  final Function(int adjustment, String? reason) onSubmit;

  const StockAdjustmentDialog({
    super.key,
    required this.product,
    required this.onSubmit,
  });

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  final _adjustmentController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isAdding = true;

  int get _adjustment {
    final value = int.tryParse(_adjustmentController.text) ?? 0;
    return _isAdding ? value : -value;
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

    return AlertDialog(
      title: Text(context.l10n.products_adjustStock),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name
            Text(
              widget.product.name,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppDimensions.marginXSmall),
            Text(
              '${context.l10n.products_currentStock}: ${widget.product.currentStock} ${widget.product.unit}',
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
            ),

            const SizedBox(height: AppDimensions.marginLarge),

            // Add/Remove toggle
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    context: context,
                    label: context.l10n.products_stockAdd,
                    icon: Icons.add,
                    isSelected: _isAdding,
                    onTap: () => setState(() => _isAdding = true),
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Expanded(
                  child: _buildToggleButton(
                    context: context,
                    label: context.l10n.products_stockRemove,
                    icon: Icons.remove,
                    isSelected: !_isAdding,
                    onTap: () => setState(() => _isAdding = false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Adjustment amount
            TextField(
              controller: _adjustmentController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: context.l10n.products_quantity,
                hintText: '0',
                suffixText: widget.product.unit,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // New stock preview
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
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
              decoration: InputDecoration(
                labelText: context.l10n.products_reason,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.common_cancel),
        ),
        ElevatedButton(
          onPressed: _canSubmit() ? _handleSubmit : null,
          child: Text(context.l10n.products_adjustStock),
        ),
      ],
    );
  }

  Widget _buildToggleButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.white
                  : theme.textTheme.bodySmall?.color,
            ),
            const SizedBox(width: AppDimensions.marginXSmall),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.white
                    : theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    final value = int.tryParse(_adjustmentController.text) ?? 0;
    return value > 0 && _newStock >= 0;
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

/// Stock Adjustment Sheet
///
/// Bottom sheet for adjusting product stock with stepper UI.
/// Shows [-] button, editable stock value, [+] button.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product.dart';
import '../providers/product_form_provider.dart';

class StockAdjustmentSheet extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback? onSuccess;

  const StockAdjustmentSheet({
    super.key,
    required this.product,
    this.onSuccess,
  });

  /// Shows the stock adjustment bottom sheet
  static void show({
    required BuildContext context,
    required Product product,
    VoidCallback? onSuccess,
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
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  ConsumerState<StockAdjustmentSheet> createState() =>
      _StockAdjustmentSheetState();
}

class _StockAdjustmentSheetState extends ConsumerState<StockAdjustmentSheet> {
  late final TextEditingController _stockController;
  String? _selectedReason;
  bool _isSubmitting = false;
  String? _errorMessage;

  int get _currentValue {
    final text = _stockController.text.trim();
    if (text.isEmpty) return 0;
    return int.tryParse(text) ?? 0;
  }

  int get _adjustment => _currentValue - widget.product.currentStock;

  bool get _hasChanged => _adjustment != 0;

  bool get _isValid => _currentValue >= 0 && _hasChanged;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.product.currentStock.toString(),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _increment() {
    final newValue = _currentValue + 1;
    _stockController.text = newValue.toString();
    setState(() {});
  }

  void _decrement() {
    if (_currentValue <= 0) return;
    final newValue = _currentValue - 1;
    _stockController.text = newValue.toString();
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    if (!_isValid) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await ref.read(productFormProvider.notifier).adjustStock(
          id: widget.product.id,
          adjustment: _adjustment,
          reason: _selectedReason,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
    } else {
      final errorMsg = ref.read(productFormProvider).errorMessage;
      setState(() => _errorMessage = errorMsg ?? context.l10n.error_generic);
    }
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

                // Product name
                Text(
                  widget.product.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppDimensions.marginXLarge),

                // Stepper row: [-]  input  [+]
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrement button
                    _StepperButton(
                      icon: Icons.remove,
                      onPressed: _currentValue > 0 ? _decrement : null,
                    ),

                    const SizedBox(width: AppDimensions.marginLarge),

                    // Editable stock value
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _adjustment > 0
                              ? AppColors.success
                              : _adjustment < 0
                                  ? AppColors.error
                                  : null,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    const SizedBox(width: AppDimensions.marginLarge),

                    // Increment button
                    _StepperButton(
                      icon: Icons.add,
                      onPressed: _increment,
                    ),
                  ],
                ),

                // Unit label
                Center(
                  child: Text(
                    widget.product.unit,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.marginMedium),

                // Adjustment indicator
                if (_hasChanged)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingMedium,
                        vertical: AppDimensions.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: _adjustment > 0
                            ? AppColors.successBackground
                            : AppColors.errorBackground,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLarge),
                      ),
                      child: Text(
                        '${_adjustment > 0 ? '+' : ''}$_adjustment ${widget.product.unit}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color:
                              _adjustment > 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Reason dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedReason,
                  decoration: InputDecoration(
                    labelText: context.l10n.products_reason,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'damaged',
                      child: Text(context.l10n.stock_reason_damaged),
                    ),
                    DropdownMenuItem(
                      value: 'lost',
                      child: Text(context.l10n.stock_reason_lost),
                    ),
                    DropdownMenuItem(
                      value: 'count_correction',
                      child: Text(context.l10n.stock_reason_countCorrection),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(context.l10n.stock_reason_other),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedReason = value),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: AppDimensions.marginMedium),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                      border:
                          Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: AppDimensions.marginSmall),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppDimensions.marginLarge),

                // Submit button
                SizedBox(
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton(
                    onPressed: _isValid && !_isSubmitting ? _handleSubmit : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(context.l10n.products_adjustStock),
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
}

/// Circular stepper button (+ or -)
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _StepperButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null;

    return Material(
      color: isDisabled
          ? theme.colorScheme.surfaceContainerHighest
          : AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: isDisabled ? theme.textTheme.bodySmall?.color : AppColors.white,
          ),
        ),
      ),
    );
  }
}

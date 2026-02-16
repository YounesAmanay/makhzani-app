/// Product Form Screen
///
/// Create/Edit product form with clean UX.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/product.dart';
import '../providers/product_form_provider.dart';
import '../providers/products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;

  const ProductFormScreen({
    super.key,
    this.productId,
  });

  bool get isEditing => productId != null;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedUnit = 'piece';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};
  Product? _product;

  static const List<String> _units = [
    'piece',
    'kg',
    'liter',
    'box',
    'carton',
    'bottle',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(productsRepositoryProvider);
      final product = await repository.getProductById(widget.productId!);

      if (mounted) {
        setState(() {
          _product = product;
          _nameController.text = product.name;
          _stockController.text = product.currentStock.toString();
          _thresholdController.text = product.reorderThreshold.toString();
          _barcodeController.text = product.barcode ?? '';
          _priceController.text = product.price?.toString() ?? '';
          _selectedUnit = product.unit;
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
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? context.l10n.products_edit : context.l10n.products_add,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.products_name} *',
                        errorText: _fieldErrors['name'],
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (_fieldErrors['name'] != null) return null;
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.validation_required;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Current Stock and Unit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _stockController,
                            decoration: InputDecoration(
                              labelText: '${context.l10n.products_currentStock} *',
                              hintText: '0',
                              errorText: _fieldErrors['current_stock'],
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (_fieldErrors['current_stock'] != null) return null;
                              if (value == null || value.trim().isEmpty) {
                                return context.l10n.validation_required;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimensions.marginMedium),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              labelText: context.l10n.products_unit,
                              errorText: _fieldErrors['unit'],
                            ),
                            items: _units.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedUnit = value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Reorder Threshold
                    TextFormField(
                      controller: _thresholdController,
                      decoration: InputDecoration(
                        labelText: '${context.l10n.products_reorderThreshold} *',
                        hintText: '10',
                        errorText: _fieldErrors['reorder_threshold'],
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (_fieldErrors['reorder_threshold'] != null) return null;
                        if (value == null || value.trim().isEmpty) {
                          return context.l10n.validation_required;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Barcode (optional)
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: context.l10n.products_barcode,
                        errorText: _fieldErrors['barcode'],
                      ),
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    // Price (optional)
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: context.l10n.products_price,
                        hintText: '0.00',
                        suffixText: context.l10n.currency_mad,
                        errorText: _fieldErrors['price'],
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginXLarge),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
                        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.errorBackground,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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

                    // Submit button
                    SizedBox(
                      height: AppDimensions.buttonHeightLarge,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? context.l10n.common_save
                                    : context.l10n.products_add,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleSubmit() async {
    // Clear previous errors before validation
    setState(() {
      _fieldErrors = {};
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final name = _nameController.text.trim();
    final currentStock = int.parse(_stockController.text.trim());
    final reorderThreshold = int.parse(_thresholdController.text.trim());
    final barcode = _barcodeController.text.trim();
    final priceText = _priceController.text.trim();
    final price = priceText.isEmpty ? null : double.tryParse(priceText);

    bool success;

    if (widget.isEditing) {
      success = await ref.read(productFormProvider.notifier).updateProduct(
            id: widget.productId!,
            name: name != _product?.name ? name : null,
            currentStock: currentStock != _product?.currentStock ? currentStock : null,
            reorderThreshold:
                reorderThreshold != _product?.reorderThreshold ? reorderThreshold : null,
            unit: _selectedUnit != _product?.unit ? _selectedUnit : null,
            barcode: barcode != (_product?.barcode ?? '')
                ? (barcode.isEmpty ? null : barcode)
                : null,
            price: price != _product?.price ? price : null,
          );
    } else {
      success = await ref.read(productFormProvider.notifier).createProduct(
            name: name,
            currentStock: currentStock,
            reorderThreshold: reorderThreshold,
            unit: _selectedUnit,
            barcode: barcode.isEmpty ? null : barcode,
            price: price,
          );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? context.l10n.products_updated : context.l10n.products_created,
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final formState = ref.read(productFormProvider);
        final fieldErrors = formState.fieldErrors;
        setState(() {
          _fieldErrors = fieldErrors;
          _errorMessage = fieldErrors.isEmpty
              ? (formState.errorMessage ?? context.l10n.error_generic)
              : null;
        });
      }
    }
  }
}

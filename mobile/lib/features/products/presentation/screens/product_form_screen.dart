/// Product Form Screen
///
/// Create/Edit product form with scan-first UX.
/// On create: shows scan hero button → auto-fills from barcode lookup.
/// On edit: loads existing product data directly into fields.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../domain/entities/barcode_result.dart';
import '../../domain/entities/product.dart';
import '../providers/product_form_provider.dart';
import '../providers/products_provider.dart';
import 'barcode_scanner_screen.dart';

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

  final _stockFocusNode = FocusNode();

  String _selectedUnit = 'piece';
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};
  Product? _product;

  // Scan state — only used in create mode
  bool _hasScanned = false;
  String? _scannedImageUrl;
  String? _dataSource;

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
    if (widget.isEditing) _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _stockFocusNode.dispose();
    super.dispose();
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Scanner
  // ---------------------------------------------------------------------------

  Future<void> _openScanner() async {
    final result = await Navigator.of(context).push<BarcodeResult?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );
    if (result == null || !mounted) return;
    _applyBarcodeResult(result);
  }

  void _applyBarcodeResult(BarcodeResult result) {
    setState(() {
      _hasScanned = true;
      _scannedImageUrl = result.imageUrl;
      _dataSource = result.sourceLabel;
      _nameController.text = result.name;
      _barcodeController.text = result.barcode;
      if (result.isHighConfidence && result.unit != null) {
        _selectedUnit = result.unit!;
      }
      // Clear any previous field errors
      _fieldErrors = {};
      _errorMessage = null;
    });

    // Announce auto-fill to user then jump focus to stock
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.products_autoFilled(result.sourceLabel)),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) FocusScope.of(context).requestFocus(_stockFocusNode);
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
                    // ── Scan hero / image (create mode only) ──────────────
                    if (!widget.isEditing) ...[
                      _hasScanned
                          ? _buildImageSection()
                          : _buildScanHeroButton(),
                      const SizedBox(height: AppDimensions.marginLarge),
                    ],

                    // ── Product Name ───────────────────────────────────────
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

                    // ── Barcode ────────────────────────────────────────────
                    TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: context.l10n.products_barcode,
                        errorText: _fieldErrors['barcode'],
                        suffixIcon: !widget.isEditing
                            ? IconButton(
                                icon: const Icon(Icons.qr_code_scanner),
                                tooltip: context.l10n.products_scanBarcode,
                                onPressed: _openScanner,
                              )
                            : null,
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),

                    const SizedBox(height: AppDimensions.marginLarge),

                    // ── Section: Stock ─────────────────────────────────────
                    _buildSectionHeader(context.l10n.products_stockSection),
                    const SizedBox(height: AppDimensions.marginMedium),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _stockController,
                            focusNode: _stockFocusNode,
                            decoration: InputDecoration(
                              labelText: '${context.l10n.products_currentStock} *',
                              hintText: '0',
                              errorText: _fieldErrors['current_stock'],
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
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
                              if (value != null) setState(() => _selectedUnit = value);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

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

                    const SizedBox(height: AppDimensions.marginLarge),

                    // ── Section: Pricing ───────────────────────────────────
                    _buildSectionHeader(context.l10n.products_pricingSection),
                    const SizedBox(height: AppDimensions.marginMedium),

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

                    // ── Generic error ──────────────────────────────────────
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

                    // ── Submit ─────────────────────────────────────────────
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

                    const SizedBox(height: AppDimensions.marginMedium),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildScanHeroButton() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 40, color: AppColors.primary),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              context.l10n.products_scanBarcode,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.l10n.products_scanSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image container
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: SizedBox(
            height: 180,
            width: double.infinity,
            child: _scannedImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: _scannedImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(child: AppLoadingIndicator()),
                    errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        // Re-scan button (top-right overlay)
        Positioned(
          top: AppDimensions.paddingSmall,
          right: AppDimensions.paddingSmall,
          child: GestureDetector(
            onTap: _openScanner,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.products_rescan,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Source badge (bottom-left overlay)
        if (_dataSource != null)
          Positioned(
            bottom: AppDimensions.paddingSmall,
            left: AppDimensions.paddingSmall,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSmall,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                _dataSource!,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceHover,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: AppColors.iconSecondary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    setState(() {
      _fieldErrors = {};
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

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
              widget.isEditing
                  ? context.l10n.products_updated
                  : context.l10n.products_created,
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

/// Product Form Screen
///
/// Create/Edit product form with scan-first UX.
/// On create: shows scan hero button → auto-fills from barcode lookup.
///            Locally-picked images are queued and uploaded after the product
///            is created (no id yet at pick time).
/// On edit: loads existing product data directly into fields.
///          Images can be uploaded / deleted immediately (id already exists).
library;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/url_helper.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/category_picker_sheet.dart';
import '../../domain/entities/barcode_result.dart';
import '../../domain/entities/product.dart';
import '../providers/categories_provider.dart';
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
  final _costPriceController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _stockFocusNode = FocusNode();

  String _selectedUnit = 'piece';
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Map<String, String> _fieldErrors = {};
  Product? _product;

  // Scan state — only used in create mode
  bool _hasScanned = false;
  String? _scannedImageUrl;
  String? _dataSource;

  // Image state
  bool _isUploadingImage = false;
  // Pending image paths for create mode (uploaded after product is created)
  final List<String> _pendingImagePaths = [];

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
    Future.microtask(() {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
    if (widget.isEditing) _loadProduct();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _nameFocusNode.dispose();
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
          _costPriceController.text = product.costPrice?.toString() ?? '';
          _selectedUnit = product.unit;
          _selectedCategoryId = product.categoryId;
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
    final isManualFill = result.name.isEmpty;

    setState(() {
      // Manual fill: barcode pre-filled but scan hero stays visible for re-scan
      if (!isManualFill) {
        _hasScanned = true;
        _scannedImageUrl = result.imageUrl;
        _dataSource = result.sourceLabel;
        _nameController.text = result.name;
      }
      _barcodeController.text = result.barcode;
      if (result.isHighConfidence && result.unit != null) {
        _selectedUnit = result.unit!;
      }
      // Clear any previous field errors
      _fieldErrors = {};
      _errorMessage = null;
    });

    if (isManualFill) {
      // Barcode pre-filled — focus name so user fills the rest
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) FocusScope.of(context).requestFocus(_nameFocusNode);
      });
    } else {
      // Auto-filled from external source — show snackbar then focus stock
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
                    // ── Images ────────────────────────────────────────────
                    _buildImagesSection(),
                    const SizedBox(height: AppDimensions.marginLarge),

                    // ── Product Name ───────────────────────────────────────
                    TextFormField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
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

                    const SizedBox(height: AppDimensions.marginMedium),

                    // ── Category ───────────────────────────────────────────
                    _buildCategoryPicker(),

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
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.marginMedium),

                    TextFormField(
                      controller: _costPriceController,
                      decoration: InputDecoration(
                        labelText: context.l10n.products_costPrice,
                        hintText: '0.00',
                        suffixText: context.l10n.currency_mad,
                        errorText: _fieldErrors['cost_price'],
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

  // ---------------------------------------------------------------------------
  // Images section
  // ---------------------------------------------------------------------------

  /// Unified images section shown in both create and edit modes.
  ///
  /// Create mode: scan hero / scanned image + horizontal list of locally-picked
  ///              images (uploaded after product creation).
  /// Edit mode:   horizontal list of server images + "Add Photo" button.
  Widget _buildImagesSection() {
    final theme = Theme.of(context);

    if (widget.isEditing) {
      // Edit mode — product already exists, show server images
      final images = _product?.images ?? [];
      final canAddMore = images.length + _pendingImagePaths.length < 5;

      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.products_photos,
                  style: theme.textTheme.titleSmall?.copyWith(
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
                height: 110,
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
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          child: Image.network(
                            UrlHelper.resolve(image.imageUrl),
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _confirmDeleteImage(_product!.id, image.id),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ] else ...[
              const SizedBox(height: AppDimensions.marginSmall),
              Center(
                child: Text(
                  context.l10n.products_addPhoto,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Create mode — scan hero + scanned image + pending local images
    final allImages = <Widget>[];

    // Scanned image or scan hero
    if (_hasScanned) {
      allImages.add(_buildScannedImageTile());
    } else {
      allImages.add(_buildScanHeroTile());
    }

    // Locally-picked images (not yet uploaded)
    for (int i = 0; i < _pendingImagePaths.length; i++) {
      allImages.add(_buildPendingImageTile(i));
    }

    // "Add photo" tile (max 5 total including scanned)
    final totalCount = (_hasScanned ? 1 : 0) + _pendingImagePaths.length;
    if (totalCount < 5) {
      allImages.add(_buildAddPhotoTile());
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.marginSmall),
        itemBuilder: (_, index) => allImages[index],
      ),
    );
  }

  Widget _buildScanHeroTile() {
    return GestureDetector(
      onTap: _openScanner,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 32, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              context.l10n.products_scanBarcode,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedImageTile() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: SizedBox(
            width: 120,
            height: 120,
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
        // Re-scan button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _openScanner,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.overlay,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner, color: AppColors.white, size: 14),
            ),
          ),
        ),
        // Source badge
        if (_dataSource != null)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.overlay,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Text(
                _dataSource!,
                style: const TextStyle(color: AppColors.white, fontSize: 9),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingImageTile(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Image.file(
            File(_pendingImagePaths[index]),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _pendingImagePaths.removeAt(index)),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoTile() {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickLocalImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.iconSecondary),
            const SizedBox(height: 6),
            Text(
              context.l10n.products_addPhoto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.image_outlined, size: 36, color: AppColors.iconSecondary),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Image actions
  // ---------------------------------------------------------------------------

  /// Create mode: pick from gallery and queue locally (upload after save).
  Future<void> _pickLocalImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null || !mounted) return;
    setState(() => _pendingImagePaths.add(image.path));
  }

  /// Edit mode: pick from gallery and upload immediately.
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null || !mounted) return;

    setState(() => _isUploadingImage = true);
    try {
      final repository = ref.read(productsRepositoryProvider);
      await repository.uploadProductImage(widget.productId!, image.path);
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

  Widget _buildCategoryPicker() {
    final categories = ref.watch(categoriesProvider).categories;

    // Resolve display label for selected category
    String selectedLabel = context.l10n.categories_selectHint;
    String? dotColor;
    if (_selectedCategoryId != null) {
      final cat = categories.where((c) => c.id == _selectedCategoryId).firstOrNull;
      if (cat != null) {
        selectedLabel = localizedCategoryName(context, cat);
        dotColor = cat.color;
      }
    }

    Color? parsedDot;
    if (dotColor != null) {
      try {
        parsedDot = Color(int.parse(dotColor.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }

    return InkWell(
      onTap: _openCategoryPicker,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.products_category,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Row(
          children: [
            if (parsedDot != null) ...[
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: parsedDot,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.marginSmall),
            ],
            Expanded(
              child: Text(
                selectedLabel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _selectedCategoryId == null
                      ? AppColors.textSecondary
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategoryPicker() async {
    final result = await CategoryPickerSheet.show(
      context: context,
      categories: ref.read(categoriesProvider).categories,
      selectedId: _selectedCategoryId,
      onSeedDefaults: _onSeedDefaultCategories,
    );

    if (!mounted) return;

    if (result == null) return; // back-dismissed, keep current selection
    if (result == CategoryPickerSheet.kNone) {
      setState(() => _selectedCategoryId = null); // "None" explicitly chosen
    } else {
      setState(() => _selectedCategoryId = result); // category chosen
    }
  }

  Future<void> _onSeedDefaultCategories() async {
    final result = await ref.read(categoriesProvider.notifier).seedDefaults();

    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.categories_loadDefaultsError),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    final msg = result.created > 0
        ? context.l10n.categories_loadDefaultsSuccess(result.created)
        : context.l10n.categories_loadDefaultsAlready;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.success,
    ));
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
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
        Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
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
    final costPriceText = _costPriceController.text.trim();
    final costPrice = costPriceText.isEmpty ? null : double.tryParse(costPriceText);

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
            costPrice: costPrice != _product?.costPrice ? costPrice : null,
            categoryId: _selectedCategoryId != _product?.categoryId
                ? _selectedCategoryId
                : null,
          );
    } else {
      success = await ref.read(productFormProvider.notifier).createProduct(
            name: name,
            currentStock: currentStock,
            reorderThreshold: reorderThreshold,
            unit: _selectedUnit,
            barcode: barcode.isEmpty ? null : barcode,
            price: price,
            costPrice: costPrice,
            categoryId: _selectedCategoryId,
          );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        // In create mode, upload the scanned image (remote URL) + any
        // locally-picked images.  All are best-effort — product is already
        // saved so we never block navigation on image upload failure.
        if (!widget.isEditing) {
          final newProductId = ref.read(productFormProvider).product?.id;
          if (newProductId != null) {
            final repository = ref.read(productsRepositoryProvider);

            // 1. Download the barcode-scanned image to a temp file, then upload
            if (_scannedImageUrl != null) {
              try {
                final tmpDir = await getTemporaryDirectory();
                final ext = _scannedImageUrl!.contains('.png') ? 'png' : 'jpg';
                final tmpPath = '${tmpDir.path}/scanned_image.$ext';
                await Dio().download(_scannedImageUrl!, tmpPath);
                await repository.uploadProductImage(newProductId, tmpPath);
                await File(tmpPath).delete(); // clean up temp file
              } catch (_) {
                // Best-effort
              }
            }

            // 2. Upload locally-picked images
            for (final path in _pendingImagePaths) {
              try {
                await repository.uploadProductImage(newProductId, path);
              } catch (_) {
                // Best-effort
              }
            }
          }
        }

        if (!mounted) return;
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

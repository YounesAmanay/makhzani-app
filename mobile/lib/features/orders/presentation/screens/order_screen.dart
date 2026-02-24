/// Order Screen
///
/// Single screen for creating a purchase order.
/// Supplier selection via tappable row → bottom sheet.
/// Product selection via multi-select picker sheet (tap to toggle).
/// Draft items shown as a list with inline qty + price fields.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/url_helper.dart';
import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../providers/order_draft_provider.dart';
import '../providers/orders_provider.dart';
import 'order_review_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productsProvider.notifier).loadProducts();
      ref.read(suppliersProvider.notifier).loadSuppliers();
      ref.read(ordersProvider.notifier).loadOrders();
    });

    // Auto-open supplier picker on first entry if no supplier selected yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(orderDraftProvider).supplierId == null) {
        _showSupplierSheet();
      }
    });
  }

  Future<void> _callSupplier(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showSupplierSheet() async {
    final suppliersState = ref.read(suppliersProvider);
    final ordersState = ref.read(ordersProvider);

    final recentIds = <String>[];
    for (final order in ordersState.orders) {
      if (!recentIds.contains(order.supplier.id)) {
        recentIds.add(order.supplier.id);
        if (recentIds.length >= 3) break;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (ctx) => _SupplierPickSheet(
        suppliers: suppliersState.allSuppliers,
        recentIds: recentIds,
        onSelect: (supplier) {
          ref.read(orderDraftProvider.notifier).setSupplier(supplier);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  Future<void> _showProductPickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (_) => const _ProductPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(orderDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orders_newOrderTitle),
      ),
      bottomNavigationBar: null,
      body: Column(
        children: [
          // Supplier row — always visible, tappable
          _buildSupplierRow(draft),

          // Body — always show order body; supplier sheet auto-opens if needed
          Expanded(
            child: Stack(
              children: [
                _buildOrderBody(draft),
                if (draft.canReview)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Save as draft immediately so the order exists
                              // before the user picks any action on review screen.
                              final success = await ref
                                  .read(orderDraftProvider.notifier)
                                  .saveDraft();
                              if (!context.mounted) return;
                              if (success) {
                                final orderId = ref
                                    .read(orderDraftProvider)
                                    .createdOrder
                                    ?.id;
                                // Reset draft — order is now persisted on server
                                ref
                                    .read(orderDraftProvider.notifier)
                                    .reset();
                                if (orderId != null && context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderReviewScreen(orderId: orderId),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                            ),
                            child: Text(context.l10n.orders_reviewOrder),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierRow(OrderDraftState draft) {
    final theme = Theme.of(context);
    final hasSupplier = draft.supplierId != null;
    final initials = draft.supplierName?.isNotEmpty == true
        ? draft.supplierName![0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium,
        0,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: _showSupplierSheet,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
        child: Row(
          children: [
            if (hasSupplier) ...[
              draft.supplierAvatarUrl != null
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        UrlHelper.resolve(draft.supplierAvatarUrl!),
                      ),
                    )
                  : CircleAvatar(
                      radius: 18,
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
                  icon: const Icon(Icons.phone_outlined, size: 20),
                  color: AppColors.primary,
                  tooltip: context.l10n.orders_callSupplier,
                  onPressed: () => _callSupplier(draft.supplierPhone!),
                ),
              const Icon(Icons.swap_horiz_outlined,
                  color: AppColors.textSecondary, size: 20),
            ] else ...[
              const Icon(Icons.person_search_outlined,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Text(
                  context.l10n.orders_selectSupplierAction,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
            ],
          ],
        ),
      ),
    ),
    ),
    );
  }

  Widget _buildOrderBody(OrderDraftState draft) {
    return Column(
      children: [
        // Fixed section header — never scrolls
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingMedium,
            AppDimensions.paddingSmall,
            AppDimensions.paddingSmall,
            AppDimensions.paddingXSmall,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.orders_products,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (draft.items.isNotEmpty)
                TextButton.icon(
                  onPressed: _showProductPickerSheet,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.orders_addProduct),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),

        // Scrollable card list
        Expanded(
          child: draft.items.isEmpty
              ? AppEmptyState(
                  icon: HugeIcons.strokeRoundedPackageAdd,
                  title: context.l10n.orders_products,
                  description: context.l10n.orders_addProductFirst,
                  actionLabel: context.l10n.orders_addProduct,
                  onAction: _showProductPickerSheet,
                )
              : ListView(
                  padding: EdgeInsets.only(
                    top: AppDimensions.paddingXSmall,
                    bottom: draft.canReview ? 100 : AppDimensions.paddingMedium,
                  ),
                  children: draft.items
                      .map((item) => _OrderItemCard(
                            key: ValueKey(item.productId),
                            item: item,
                            onQtyChanged: (qty) => ref
                                .read(orderDraftProvider.notifier)
                                .updateQuantity(item.productId, qty),
                            onPriceChanged: (price) => ref
                                .read(orderDraftProvider.notifier)
                                .updatePrice(item.productId, price),
                            onRemove: () => ref
                                .read(orderDraftProvider.notifier)
                                .removeProduct(item.productId),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

// ── Order Item Card ───────────────────────────────────────────────────────────
// White card with left accent bar, product name + delete on top,
// stacked Qty and Price text fields below.

class _OrderItemCard extends StatefulWidget {
  final OrderDraftItem item;
  final ValueChanged<double> onQtyChanged;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback onRemove;

  const _OrderItemCard({
    super.key,
    required this.item,
    required this.onQtyChanged,
    required this.onPriceChanged,
    required this.onRemove,
  });

  @override
  State<_OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<_OrderItemCard> {
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    final qty = widget.item.quantity;
    _qtyController = TextEditingController(
      text: qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1),
    );
    _priceController = TextEditingController(
      text: widget.item.unitPrice > 0
          ? widget.item.unitPrice.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Left accent bar
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  color: AppColors.primary,
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppDimensions.paddingMedium + 4,
                  AppDimensions.paddingMedium,
                  AppDimensions.paddingSmall,
                  AppDimensions.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: name + delete
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.productName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.item.productUnit.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.item.productUnit,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: AppColors.error,
                          tooltip: context.l10n.orders_remove,
                          onPressed: widget.onRemove,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),

                    // Qty field — full width
                    TextField(
                      controller: _qtyController,
                      decoration: InputDecoration(
                        labelText: context.l10n.orders_quantity,
                        suffixText: widget.item.productUnit.isNotEmpty
                            ? widget.item.productUnit
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      textInputAction: TextInputAction.next,
                      onChanged: (v) {
                        final qty = double.tryParse(v);
                        if (qty != null && qty > 0) widget.onQtyChanged(qty);
                      },
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),

                    // Price field — full width
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: context.l10n.orders_unitPrice,
                        suffixText: context.l10n.currency_mad,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      textInputAction: TextInputAction.done,
                      onChanged: (v) {
                        final price = double.tryParse(v) ?? 0.0;
                        widget.onPriceChanged(price);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supplier Pick Bottom Sheet ──────────────────────────────────────────────

class _SupplierPickSheet extends ConsumerStatefulWidget {
  final List<Supplier> suppliers;
  final List<String> recentIds;
  final ValueChanged<Supplier> onSelect;

  const _SupplierPickSheet({
    required this.suppliers,
    required this.recentIds,
    required this.onSelect,
  });

  @override
  ConsumerState<_SupplierPickSheet> createState() => _SupplierPickSheetState();
}

class _SupplierPickSheetState extends ConsumerState<_SupplierPickSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suppliersState = ref.watch(suppliersProvider);

    final filtered = _query.isEmpty
        ? suppliersState.allSuppliers
        : suppliersState.allSuppliers
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                (s.businessName
                        ?.toLowerCase()
                        .contains(_query.toLowerCase()) ??
                    false))
            .toList();

    final recentSuppliers = widget.recentIds
        .map((id) {
          try {
            return suppliersState.allSuppliers
                .firstWhere((s) => s.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Supplier>()
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Text(
              context.l10n.orders_selectSupplier,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: context.l10n.orders_selectSupplierHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),

          // List
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                if (_query.isEmpty && recentSuppliers.isNotEmpty) ...[
                  _sheetSectionHeader(context.l10n.orders_recentSuppliers, theme),
                  ...recentSuppliers.map(
                    (s) => _SupplierPickTile(supplier: s, onSelect: widget.onSelect),
                  ),
                  _sheetSectionHeader(context.l10n.orders_allSuppliers, theme),
                ],
                ...filtered.map(
                  (s) => _SupplierPickTile(supplier: s, onSelect: widget.onSelect),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetSectionHeader(String label, ThemeData theme) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingMedium,
          AppDimensions.paddingSmall,
          AppDimensions.paddingMedium,
          AppDimensions.paddingXSmall,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _SupplierPickTile extends StatelessWidget {
  final Supplier supplier;
  final ValueChanged<Supplier> onSelect;

  const _SupplierPickTile({
    required this.supplier,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: () => onSelect(supplier),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                // Avatar
                supplier.avatarUrl != null
                    ? CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                          UrlHelper.resolve(supplier.avatarUrl!),
                        ),
                      )
                    : CircleAvatar(
                        radius: 22,
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

                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.marginXSmall),
                      Text(
                        supplier.businessName?.isNotEmpty == true
                            ? supplier.businessName!
                            : supplier.phoneNumber,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (supplier.relationship != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.suppliers_totalOrders(
                            supplier.relationship!.totalOrders,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Product Picker Bottom Sheet ───────────────────────────────────────────────
// Tap a product to immediately add/remove it from the draft.

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsState = ref.watch(productsProvider);
    final draft = ref.watch(orderDraftProvider);

    final allProducts = productsState.products;
    final filtered = _query.isEmpty
        ? allProducts
        : allProducts
            .where(
                (p) => p.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.orders_addProduct,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (draft.itemCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      '${draft.itemCount}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: false,
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
          const SizedBox(height: AppDimensions.marginSmall),

          // Product list
          Expanded(
            child: productsState.status == ProductsStatus.loading
                ? const AppLoadingScreen()
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.products_noResults,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final product = filtered[index];
                          final inOrder = draft.hasProduct(product.id);
                          return _ProductPickerTile(
                            product: product,
                            inOrder: inOrder,
                            onTap: () {
                              if (inOrder) {
                                ref
                                    .read(orderDraftProvider.notifier)
                                    .removeProduct(product.id);
                              } else {
                                ref
                                    .read(orderDraftProvider.notifier)
                                    .addProduct(product);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProductPickerTile extends StatelessWidget {
  final Product product;
  final bool inOrder;
  final VoidCallback onTap;

  const _ProductPickerTile({
    required this.product,
    required this.inOrder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOutOfStock = product.currentStock <= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingXSmall,
      ),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(
                color: inOrder
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outlineVariant,
                width: inOrder ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppDimensions.marginXSmall),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isOutOfStock
                                  ? context.l10n.orders_outOfStock
                                  : context.l10n.orders_stockLabel(
                                      product.currentStock.toInt(),
                                      product.unit,
                                    ),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isOutOfStock
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          if (product.price != null) ...[
                            const SizedBox(width: AppDimensions.marginSmall),
                            Text(
                              '${product.price!.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: inOrder
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(
                    inOrder ? Icons.check : Icons.add,
                    color: inOrder ? Colors.white : AppColors.primary,
                    size: 16,
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

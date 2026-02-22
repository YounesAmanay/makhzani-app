import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/screens/barcode_scanner_screen.dart';
import '../providers/sale_cart_provider.dart';
import '../providers/sales_provider.dart';
import '../widgets/cart_product_tile.dart';
import '../widgets/sale_history_tile.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  int _tabIndex = 0; // 0 = New Sale, 1 = History
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productsProvider.notifier).loadProducts();
      ref.read(salesProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(context.l10n.sales_title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              0,
              AppDimensions.paddingMedium,
              AppDimensions.paddingSmall,
            ),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text(context.l10n.sales_newSale),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedShoppingCart01,
                    size: 16,
                    color: _tabIndex == 0 ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text(context.l10n.sales_history),
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    size: 16,
                    color: _tabIndex == 1 ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (s) => setState(() => _tabIndex = s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.primary;
                  return theme.colorScheme.surface;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.white;
                  return AppColors.textSecondary;
                }),
              ),
            ),
          ),
        ),
      ),
      body: _tabIndex == 0 ? _buildCart() : _buildHistory(),
    );
  }

  // ─── Cart View ──────────────────────────────────────────────────────────────

  Widget _buildCart() {
    final cartState = ref.watch(cartProvider);
    final productsState = ref.watch(productsProvider);
    final allProducts = productsState.products;

    final filtered = _searchQuery.isEmpty
        ? <Product>[]
        : allProducts
            .where((p) =>
                p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (p.barcode?.contains(_searchQuery) ?? false))
            .take(6)
            .toList();

    // Search bar height is fixed; the dropdown overlays the cart list via Stack.
    final searchBar = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingSmall,
        AppDimensions.paddingMedium,
        0,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: context.l10n.sales_searchProducts,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedBarCode01,
                    size: AppDimensions.iconMedium,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Scan',
                  onPressed: () => _scanBarcode(),
                ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );

    final dropdown = filtered.isNotEmpty
        ? Positioned(
            top: 56, // below the search bar (~48px field + 8px padding)
            left: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    return ListTile(
                      dense: true,
                      title: Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${p.currentStock} ${p.unit} • ${p.price?.toStringAsFixed(2) ?? '—'} ${context.l10n.currency_mad}',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedPlusSign,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onTap: () => _addToCart(p),
                    );
                  },
                ),
              ),
            ),
          )
        : null;

    return Stack(
      children: [
        // Main layout: search bar + cart list + bottom bar
        Column(
          children: [
            searchBar,
            // Cart items
            Expanded(
              child: cartState.items.isEmpty
                  ? AppEmptyState(
                      icon: HugeIcons.strokeRoundedShoppingCart01,
                      title: context.l10n.sales_cartEmpty,
                      description: context.l10n.sales_cartEmptyDescription,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.paddingSmall,
                        bottom: 120,
                      ),
                      itemCount: cartState.items.length,
                      itemBuilder: (context, i) =>
                          CartProductTile(item: cartState.items[i]),
                    ),
            ),
            // Bottom bar: total + confirm
            if (cartState.items.isNotEmpty) _buildCartBottom(cartState),
          ],
        ),
        // Floating dropdown overlays the cart list without displacing it
        if (dropdown != null) dropdown,
      ],
    );
  }

  Widget _buildCartBottom(CartState cartState) {
    final isSubmitting = cartState.status == CartStatus.submitting;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingMedium,
        AppDimensions.paddingSmall,
        AppDimensions.paddingMedium,
        AppDimensions.paddingMedium + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.sales_total,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${cartState.totalAmount.toStringAsFixed(2)} ${context.l10n.currency_mad}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightMedium,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () => _confirmSale(cartState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: isSubmitting
                  ? const AppButtonLoading()
                  : Text(
                      context.l10n.sales_confirmSale,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    _searchController.clear();
    setState(() => _searchQuery = '');

    if (product.price == null || product.price == 0) {
      _showPriceSheet(product);
    } else {
      ref.read(cartProvider.notifier).addProduct(product);
    }
  }

  Future<void> _showPriceSheet(Product product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (ctx) => _PriceSheet(
        product: product,
        onConfirm: (price) {
          ref.read(cartProvider.notifier).addProduct(
                product,
                overridePrice: price,
              );
        },
      ),
    );
  }

  Future<void> _confirmSale(CartState cartState) async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.sales_confirmTitle,
      message: context.l10n.sales_confirmMessage(cartState.totalItemCount),
    );
    if (confirmed != true) return;

    final sale = await ref.read(cartProvider.notifier).confirmSale();

    if (!mounted) return;

    final currentState = ref.read(cartProvider);
    if (currentState.status == CartStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentState.errorMessage ?? context.l10n.error_generic),
          backgroundColor: AppColors.error,
        ),
      );
      ref.read(cartProvider.notifier).resetStatus();
      return;
    }

    if (sale != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.sales_success),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: context.l10n.sales_shareReceipt,
            textColor: AppColors.white,
            onPressed: () {
              final date = '${sale.createdAt.day}/${sale.createdAt.month}/${sale.createdAt.year}';
              final text = context.l10n.sales_receiptText(
                sale.saleNumber,
                date,
                sale.totalAmount.toStringAsFixed(2),
              );
              SharePlus.instance.share(ShareParams(text: text));
            },
          ),
        ),
      );
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const BarcodeScannerScreen(rawMode: true),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _searchQuery = result;
        _searchController.text = result;
      });
    }
  }

  // ─── History View ───────────────────────────────────────────────────────────

  Widget _buildHistory() {
    final state = ref.watch(salesProvider);

    switch (state.status) {
      case SalesStatus.initial:
      case SalesStatus.loading:
        return const AppLoadingScreen();
      case SalesStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(salesProvider.notifier).load(),
        );
      case SalesStatus.loaded:
        if (state.sales.isEmpty) {
          return AppEmptyState(
            icon: HugeIcons.strokeRoundedSaleTag01,
            title: context.l10n.sales_noHistory,
            description: context.l10n.sales_noHistoryDescription,
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(salesProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.only(
              top: AppDimensions.paddingSmall,
              bottom: AppDimensions.paddingLarge,
            ),
            itemCount: state.sales.length,
            itemBuilder: (context, i) {
              final sale = state.sales[i];
              return SaleHistoryTile(
                sale: sale,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SaleDetailScreen(sale: sale),
                  ),
                ),
              );
            },
          ),
        );
    }
  }
}

class _PriceSheet extends StatefulWidget {
  final Product product;
  final void Function(double price) onConfirm;

  const _PriceSheet({required this.product, required this.onConfirm});

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge,
        AppDimensions.paddingLarge + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.sales_enterPrice,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppDimensions.marginXSmall),
            Text(
              context.l10n.sales_enterPriceMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.l10n.sales_unitPrice,
                hintText: context.l10n.sales_priceHint,
                suffixText: context.l10n.currency_mad,
              ),
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) {
                  return context.l10n.sales_noPriceError;
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.marginLarge),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightMedium,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final price = double.parse(_controller.text);
                    Navigator.of(context).pop();
                    widget.onConfirm(price);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: Text(context.l10n.common_add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

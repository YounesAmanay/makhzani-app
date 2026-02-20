/// Orders Screen
///
/// Main orders list with pagination and inline filter chips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_provider.dart';
import '../providers/order_draft_provider.dart';
import '../widgets/order_list_tile.dart';
import '../widgets/supplier_picker_sheet.dart';
import 'order_screen.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(ordersProvider.notifier).loadOrders();
      ref.read(suppliersProvider.notifier).loadSuppliers();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(ordersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersProvider);
    final suppliersState = ref.watch(suppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orders_title),
      ),
      body: Column(
        children: [
          // Search bar
          AppSearchBar(
            hintText: context.l10n.orders_searchHint,
            onSearch: (query) =>
                ref.read(ordersProvider.notifier).filterBySearch(query),
          ),

          // Inline filter chips — always visible
          _buildFilterChips(ordersState, suppliersState),

          // Body
          Expanded(child: _buildBody(ordersState)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'orders_fab',
        onPressed: () {
          ref.read(orderDraftProvider.notifier).reset();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OrderScreen(),
            ),
          );
        },
        tooltip: context.l10n.orders_add,
        child: HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChips(OrdersState ordersState, SuppliersState suppliersState) {
    final selectedStatus = ordersState.selectedStatus;
    final selectedSupplierId = ordersState.selectedSupplierId;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Row(
          children: [
            // Status: All
            AppFilterChip(
              label: context.l10n.orders_filterAll,
              isActive: selectedStatus == 'all',
              showClose: false,
              onTap: () => ref.read(ordersProvider.notifier).filterByStatus('all'),
            ),
            const SizedBox(width: AppDimensions.marginSmall),

            // Status: Draft
            AppFilterChip(
              label: context.l10n.orders_statusDraft,
              isActive: selectedStatus == 'draft',
              showClose: false,
              onTap: () => ref.read(ordersProvider.notifier).filterByStatus('draft'),
            ),
            const SizedBox(width: AppDimensions.marginSmall),

            // Status: Sent
            AppFilterChip(
              label: context.l10n.orders_statusSent,
              isActive: selectedStatus == 'sent',
              showClose: false,
              onTap: () => ref.read(ordersProvider.notifier).filterByStatus('sent'),
            ),
            const SizedBox(width: AppDimensions.marginSmall),

            // Supplier chip
            AppFilterChip(
              label: selectedSupplierId != null
                  ? _getSupplierName(selectedSupplierId, suppliersState)
                  : context.l10n.orders_filterAllSuppliers,
              isActive: selectedSupplierId != null,
              showClose: selectedSupplierId != null,
              onTap: selectedSupplierId != null
                  ? () => ref.read(ordersProvider.notifier).filterBySupplier(null)
                  : () => _showSupplierPicker(ordersState, suppliersState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(OrdersState state) {
    switch (state.status) {
      case OrdersStatus.initial:
      case OrdersStatus.loading:
        return const AppLoadingScreen();

      case OrdersStatus.error:
        return AppErrorState(
          message: state.errorMessage ?? context.l10n.error_generic,
          onRetry: () => ref.read(ordersProvider.notifier).refresh(),
        );

      case OrdersStatus.loaded:
      case OrdersStatus.loadingMore:
        final orders = state.orders;
        if (orders.isEmpty) return _buildEmptyState(state);
        return _buildOrdersList(orders, state);
    }
  }

  Widget _buildEmptyState(OrdersState state) {
    if (state.hasActiveFilters) {
      return AppEmptyState(
        icon: HugeIcons.strokeRoundedSearchRemove,
        title: context.l10n.orders_empty,
        description: context.l10n.suppliers_adjustFilters,
      );
    }

    return AppEmptyState(
      icon: HugeIcons.strokeRoundedInvoice02,
      title: context.l10n.orders_empty,
      description: context.l10n.orders_emptyDescription,
      actionLabel: context.l10n.orders_add,
      onAction: () {
        ref.read(orderDraftProvider.notifier).reset();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const OrderScreen(),
          ),
        );
      },
    );
  }

  Widget _buildOrdersList(List<Order> orders, OrdersState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppDimensions.paddingMedium,
          bottom: AppDimensions.fabClearance,
        ),
        itemCount: orders.length + (state.status == OrdersStatus.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Center(child: AppLoadingIndicator()),
            );
          }

          final order = orders[index];
          return OrderListTile(
            order: order,
            onTap: () {
              Navigator.of(context).pushNamed(
                '/orders/detail',
                arguments: order.id,
              );
            },
          );
        },
      ),
    );
  }

  String _getSupplierName(String supplierId, SuppliersState suppliersState) {
    if (suppliersState.allSuppliers.isEmpty) return '...';
    for (final supplier in suppliersState.allSuppliers) {
      if (supplier.id == supplierId) return supplier.name;
    }
    return '...';
  }

  Future<void> _showSupplierPicker(
    OrdersState ordersState,
    SuppliersState suppliersState,
  ) async {
    final supplierId = await SupplierPickerSheet.show(
      context: context,
      suppliers: suppliersState.allSuppliers,
      selectedSupplierId: ordersState.selectedSupplierId,
    );
    if (supplierId != null) {
      ref.read(ordersProvider.notifier).filterBySupplier(supplierId);
    }
  }
}

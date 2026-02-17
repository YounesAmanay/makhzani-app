/// Orders Screen
///
/// Main orders list with pagination and filters (supplier, status).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../suppliers/presentation/providers/suppliers_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_filters_sheet.dart';
import '../widgets/order_list_tile.dart';

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
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(context, ordersState, suppliersState),
            tooltip: context.l10n.common_filter,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (ordersState.hasActiveFilters) _buildActiveFilters(ordersState),

          // Body
          Expanded(child: _buildBody(ordersState)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/orders/create');
        },
        tooltip: context.l10n.orders_add,
        child: const Icon(Icons.add),
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
        icon: Icons.search_off,
        title: context.l10n.orders_empty,
        description: context.l10n.suppliers_adjustFilters,
      );
    }

    return AppEmptyState(
      icon: Icons.receipt_long_outlined,
      title: context.l10n.orders_empty,
      description: context.l10n.orders_emptyDescription,
      actionLabel: context.l10n.orders_add,
      onAction: () {
        Navigator.of(context).pushNamed('/orders/create');
      },
    );
  }

  Widget _buildOrdersList(List orders, OrdersState state) {
    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          top: AppDimensions.paddingSmall,
          bottom: 80,
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
              // TODO: Navigate to order detail screen
              debugPrint('View order: ${order.id}');
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveFilters(OrdersState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: AppDimensions.marginSmall,
          children: [
            if (state.selectedStatus != 'all')
              FilterChip(
                label: Text(_getStatusLabel(state.selectedStatus)),
                onSelected: (_) {
                  ref.read(ordersProvider.notifier).filterByStatus('all');
                },
                selected: true,
                showCheckmark: false,
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  ref.read(ordersProvider.notifier).filterByStatus('all');
                },
              ),
            if (state.selectedSupplierId != null)
              FilterChip(
                label: Text(_getSupplierName(state.selectedSupplierId!)),
                onSelected: (_) {
                  ref.read(ordersProvider.notifier).filterBySupplier(null);
                },
                selected: true,
                showCheckmark: false,
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  ref.read(ordersProvider.notifier).filterBySupplier(null);
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'draft':
        return context.l10n.orders_statusDraft;
      case 'sent':
        return context.l10n.orders_statusSent;
      default:
        return context.l10n.orders_filterAll;
    }
  }

  String _getSupplierName(String supplierId) {
    final suppliersState = ref.read(suppliersProvider);
    final supplier = suppliersState.allSuppliers.firstWhere(
      (s) => s.id == supplierId,
      orElse: () => suppliersState.allSuppliers.first,
    );
    return supplier.name;
  }

  void _showFilters(
    BuildContext context,
    OrdersState ordersState,
    SuppliersState suppliersState,
  ) {
    OrderFiltersSheet.show(
      context: context,
      selectedSupplierId: ordersState.selectedSupplierId,
      selectedStatus: ordersState.selectedStatus,
      suppliers: suppliersState.allSuppliers,
      onApply: (supplierId, status) {
        if (supplierId != ordersState.selectedSupplierId) {
          ref.read(ordersProvider.notifier).filterBySupplier(supplierId);
        }
        if (status != ordersState.selectedStatus) {
          ref.read(ordersProvider.notifier).filterByStatus(status);
        }
      },
    );
  }
}

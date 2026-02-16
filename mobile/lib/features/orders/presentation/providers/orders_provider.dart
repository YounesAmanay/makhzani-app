/// Orders Provider
///
/// Riverpod provider for orders list state management with pagination and filters.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/orders_repository.dart';

const _sentinel = Object();

enum OrdersStatus { initial, loading, loaded, loadingMore, error }

class OrdersState {
  final OrdersStatus status;
  final List<Order> orders;
  final OrderPagination? pagination;
  final String? selectedSupplierId;
  final String selectedStatus; // 'all', 'draft', 'sent'
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.pagination,
    this.selectedSupplierId,
    this.selectedStatus = 'all',
    this.errorMessage,
  });

  bool get hasMore => pagination?.hasNextPage ?? false;
  int get currentPage => pagination?.currentPage ?? 1;
  bool get hasActiveFilters =>
      selectedSupplierId != null || selectedStatus != 'all';

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    OrderPagination? pagination,
    Object? selectedSupplierId = _sentinel,
    String? selectedStatus,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      pagination: pagination ?? this.pagination,
      selectedSupplierId: selectedSupplierId == _sentinel
          ? this.selectedSupplierId
          : selectedSupplierId as String?,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      errorMessage: errorMessage,
    );
  }
}

class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrdersRepository _repository;

  OrdersNotifier(this._repository) : super(const OrdersState());

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        status: OrdersStatus.loading,
        errorMessage: null,
      );
    } else if (state.status == OrdersStatus.initial) {
      state = state.copyWith(status: OrdersStatus.loading);
    }

    try {
      final result = await _repository.getOrders(
        page: 1,
        supplierId: state.selectedSupplierId,
        status: state.selectedStatus,
      );

      state = state.copyWith(
        status: OrdersStatus.loaded,
        orders: result.orders,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: 'Failed to load orders',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == OrdersStatus.loadingMore) {
      return;
    }

    state = state.copyWith(status: OrdersStatus.loadingMore);

    try {
      final result = await _repository.getOrders(
        page: state.currentPage + 1,
        supplierId: state.selectedSupplierId,
        status: state.selectedStatus,
      );

      state = state.copyWith(
        status: OrdersStatus.loaded,
        orders: [...state.orders, ...result.orders],
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        status: OrdersStatus.loaded,
        errorMessage: 'Failed to load more orders',
      );
    }
  }

  Future<void> filterBySupplier(String? supplierId) async {
    if (supplierId == state.selectedSupplierId) return;

    state = state.copyWith(
      selectedSupplierId: supplierId,
      status: OrdersStatus.loading,
    );

    await loadOrders(refresh: true);
  }

  Future<void> filterByStatus(String status) async {
    if (status == state.selectedStatus) return;

    state = state.copyWith(
      selectedStatus: status,
      status: OrdersStatus.loading,
    );

    await loadOrders(refresh: true);
  }

  Future<void> refresh() async {
    await loadOrders(refresh: true);
  }
}

// Providers
final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.read(ordersRemoteDataSourceProvider));
});

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  return OrdersNotifier(ref.read(ordersRepositoryProvider));
});

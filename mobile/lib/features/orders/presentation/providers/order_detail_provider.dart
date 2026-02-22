/// Order Detail Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_provider.dart';

enum OrderDetailStatus { loading, loaded, error }

class OrderDetailState {
  final OrderDetailStatus status;
  final OrderDetail? order;
  final String? errorMessage;
  final bool isGeneratingPdf;
  final bool isMarkingSent;
  final bool isReceiving;

  OrderDetailState({
    required this.status,
    this.order,
    this.errorMessage,
    this.isGeneratingPdf = false,
    this.isMarkingSent = false,
    this.isReceiving = false,
  });

  OrderDetailState copyWith({
    OrderDetailStatus? status,
    OrderDetail? order,
    String? errorMessage,
    bool? isGeneratingPdf,
    bool? isMarkingSent,
    bool? isReceiving,
  }) {
    return OrderDetailState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      isMarkingSent: isMarkingSent ?? this.isMarkingSent,
      isReceiving: isReceiving ?? this.isReceiving,
    );
  }
}

class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final OrdersRepository _repository;
  final Ref _ref;

  OrderDetailNotifier(this._repository, this._ref)
      : super(OrderDetailState(status: OrderDetailStatus.loading));

  Future<void> loadOrder(String orderId) async {
    state = OrderDetailState(status: OrderDetailStatus.loading);

    try {
      final order = await _repository.getOrder(orderId);
      state = OrderDetailState(
        status: OrderDetailStatus.loaded,
        order: order,
      );
    } catch (e) {
      state = OrderDetailState(
        status: OrderDetailStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Generates PDF and returns the server-relative URL to open immediately.
  /// Returns null on failure (errorMessage is set in state).
  Future<String?> generateAndOpenPdf() async {
    if (state.order == null) return null;

    state = state.copyWith(isGeneratingPdf: true);

    try {
      final pdfUrl = await _repository.generatePdf(state.order!.id);
      // Re-fetch to update local order status
      final updatedOrder = await _repository.getOrder(state.order!.id);
      state = OrderDetailState(
        status: OrderDetailStatus.loaded,
        order: updatedOrder,
      );
      _ref.read(ordersProvider.notifier).refresh();
      return pdfUrl;
    } catch (e) {
      state = state.copyWith(
        isGeneratingPdf: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Marks the order as sent via the given channel and refreshes state.
  Future<bool> markSent(String sentVia) async {
    if (state.order == null) return false;

    state = state.copyWith(isMarkingSent: true);

    try {
      await _repository.markSent(state.order!.id, sentVia);
      final updatedOrder = await _repository.getOrder(state.order!.id);
      state = OrderDetailState(
        status: OrderDetailStatus.loaded,
        order: updatedOrder,
      );
      _ref.read(ordersProvider.notifier).refresh();
      _ref.read(dashboardProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(
        isMarkingSent: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Receives the order, auto-updating stock for all items.
  /// Returns true on success. The order must not already be received.
  Future<bool> receiveOrder() async {
    if (state.order == null) return false;

    state = state.copyWith(isReceiving: true);

    try {
      await _repository.receiveOrder(state.order!.id);
      final updatedOrder = await _repository.getOrder(state.order!.id);
      state = OrderDetailState(
        status: OrderDetailStatus.loaded,
        order: updatedOrder,
      );
      _ref.read(ordersProvider.notifier).refresh();
      _ref.read(dashboardProvider.notifier).refresh();
      return true;
    } catch (e) {
      state = state.copyWith(
        isReceiving: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void refresh() {
    if (state.order != null) {
      loadOrder(state.order!.id);
    }
  }
}

final orderDetailProvider =
    StateNotifierProvider.family<OrderDetailNotifier, OrderDetailState, String>(
  (ref, orderId) {
    final repository = ref.read(ordersRepositoryProvider);
    final notifier = OrderDetailNotifier(repository, ref);
    notifier.loadOrder(orderId);
    return notifier;
  },
);

/// Order Detail Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  OrderDetailState({
    required this.status,
    this.order,
    this.errorMessage,
    this.isGeneratingPdf = false,
    this.isMarkingSent = false,
  });

  OrderDetailState copyWith({
    OrderDetailStatus? status,
    OrderDetail? order,
    String? errorMessage,
    bool? isGeneratingPdf,
    bool? isMarkingSent,
  }) {
    return OrderDetailState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage,
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      isMarkingSent: isMarkingSent ?? this.isMarkingSent,
    );
  }
}

class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final OrdersRepository _repository;

  OrderDetailNotifier(this._repository)
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

  Future<bool> generatePdf() async {
    if (state.order == null) return false;

    state = state.copyWith(isGeneratingPdf: true);

    try {
      await _repository.generatePdf(state.order!.id);
      // Re-fetch full order to get updated status
      final updatedOrder = await _repository.getOrder(state.order!.id);
      state = OrderDetailState(
        status: OrderDetailStatus.loaded,
        order: updatedOrder,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isGeneratingPdf: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> markSent(String sentVia) async {
    if (state.order == null) return false;

    state = state.copyWith(isMarkingSent: true);

    try {
      await _repository.markSent(state.order!.id, sentVia);
      // Re-fetch full order to get updated status
      final updatedOrder = await _repository.getOrder(state.order!.id);
      state = OrderDetailState(
        status: OrderDetailStatus.loaded,
        order: updatedOrder,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isMarkingSent: false,
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
    final notifier = OrderDetailNotifier(repository);
    notifier.loadOrder(orderId);
    return notifier;
  },
);

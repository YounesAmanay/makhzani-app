/// Order Form Provider
///
/// Riverpod provider for order create/edit operations with dynamic line items.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_provider.dart';

enum OrderFormStatus { idle, loading, success, error }

class OrderItemInput {
  final String? productId;
  final String? productName;
  final String? productUnit;
  final double? quantity;
  final double? unitPrice;

  const OrderItemInput({
    this.productId,
    this.productName,
    this.productUnit,
    this.quantity,
    this.unitPrice,
  });

  double get total => (quantity ?? 0) * (unitPrice ?? 0);
  bool get isValid => productId != null && quantity != null && quantity! > 0;

  OrderItemInput copyWith({
    String? productId,
    String? productName,
    String? productUnit,
    double? quantity,
    double? unitPrice,
  }) {
    return OrderItemInput(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productUnit: productUnit ?? this.productUnit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class OrderFormState {
  final OrderFormStatus status;
  final String? supplierId;
  final List<OrderItemInput> items;
  final String? notes;
  final Order? createdOrder;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const OrderFormState({
    this.status = OrderFormStatus.idle,
    this.supplierId,
    this.items = const [],
    this.notes,
    this.createdOrder,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  double get totalValue => items.fold(0, (sum, item) => sum + item.total);
  double get totalQuantity => items.fold(0.0, (sum, item) => sum + (item.quantity ?? 0));
  bool get canSubmit =>
      supplierId != null &&
      items.isNotEmpty &&
      items.every((i) => i.isValid);

  OrderFormState copyWith({
    OrderFormStatus? status,
    String? supplierId,
    List<OrderItemInput>? items,
    String? notes,
    Order? createdOrder,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return OrderFormState(
      status: status ?? this.status,
      supplierId: supplierId ?? this.supplierId,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      createdOrder: createdOrder ?? this.createdOrder,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

class OrderFormNotifier extends StateNotifier<OrderFormState> {
  final OrdersRepository _repository;
  final Ref _ref;

  OrderFormNotifier(this._repository, this._ref)
      : super(const OrderFormState());

  void reset() {
    state = const OrderFormState();
  }

  void setSupplier(String? supplierId) {
    state = state.copyWith(supplierId: supplierId);
  }

  void addItem() {
    state = state.copyWith(
      items: [...state.items, const OrderItemInput()],
    );
  }

  void removeItem(int index) {
    final newItems = List<OrderItemInput>.from(state.items);
    newItems.removeAt(index);
    state = state.copyWith(items: newItems);
  }

  void updateItem(int index, OrderItemInput item) {
    final newItems = List<OrderItemInput>.from(state.items);
    newItems[index] = item;
    state = state.copyWith(items: newItems);
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  Future<bool> createOrder() async {
    if (!state.canSubmit) return false;

    state = state.copyWith(
      status: OrderFormStatus.loading,
      errorMessage: null,
      fieldErrors: {},
    );

    try {
      final items = state.items.map((item) {
        return <String, dynamic>{
          'product_id': item.productId!,
          'quantity': item.quantity!,
          if (item.unitPrice != null) 'unit_price': item.unitPrice,
        };
      }).toList();

      final order = await _repository.createOrder(
        supplierId: state.supplierId!,
        items: items,
        notes: state.notes,
      );

      state = state.copyWith(
        status: OrderFormStatus.success,
        createdOrder: order,
      );

      // Refresh orders list and dashboard stats
      _ref.read(ordersProvider.notifier).refresh();
      _ref.read(dashboardProvider.notifier).refresh();

      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  void _handleError(dynamic e) {
    String errorMessage = e.toString();
    Map<String, String> fieldErrors = {};

    if (e is DioException && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        // Parse field-level validation errors
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          for (final error in errors) {
            if (error is Map) {
              final field = error['path'] as String?;
              final msg = error['msg'] as String?;
              if (field != null && msg != null) {
                fieldErrors[field] = msg;
              }
            }
          }
        }
        errorMessage = data['message'] ?? errorMessage;
      }
    }

    state = state.copyWith(
      status: OrderFormStatus.error,
      errorMessage: fieldErrors.isEmpty ? errorMessage : null,
      fieldErrors: fieldErrors,
    );
  }
}

// Provider
final orderFormProvider =
    StateNotifierProvider<OrderFormNotifier, OrderFormState>((ref) {
  return OrderFormNotifier(
    ref.read(ordersRepositoryProvider),
    ref,
  );
});

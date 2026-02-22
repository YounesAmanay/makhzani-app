/// Order Draft Provider
///
/// Shared state for the 3-step order creation flow:
/// Step 1 (supplier pick) → Step 2 (build items) → Step 3 (review & send)
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../products/domain/entities/product.dart';
import '../../../suppliers/domain/entities/supplier.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import 'orders_provider.dart';

enum OrderDraftStatus { idle, loading, success, error }

class OrderDraftItem {
  final String productId;
  final String productName;
  final String productUnit;
  final double quantity;
  final double unitPrice;

  const OrderDraftItem({
    required this.productId,
    required this.productName,
    required this.productUnit,
    this.quantity = 1.0,
    this.unitPrice = 0.0,
  });

  double get total => quantity * unitPrice;

  OrderDraftItem copyWith({
    double? quantity,
    double? unitPrice,
  }) {
    return OrderDraftItem(
      productId: productId,
      productName: productName,
      productUnit: productUnit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}

class OrderDraftState {
  final String? supplierId;
  final String? supplierName;
  final String? supplierPhone;
  final String? supplierAvatarUrl;
  final List<OrderDraftItem> items;
  final String? notes;
  final OrderDraftStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final Order? createdOrder;

  const OrderDraftState({
    this.supplierId,
    this.supplierName,
    this.supplierPhone,
    this.supplierAvatarUrl,
    this.items = const [],
    this.notes,
    this.status = OrderDraftStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
    this.createdOrder,
  });

  double get totalValue => items.fold(0, (s, i) => s + i.total);
  int get itemCount => items.length;
  bool get canReview => supplierId != null && items.isNotEmpty;
  bool hasProduct(String productId) => items.any((i) => i.productId == productId);

  OrderDraftState copyWith({
    String? supplierId,
    String? supplierName,
    String? supplierPhone,
    String? supplierAvatarUrl,
    List<OrderDraftItem>? items,
    String? notes,
    OrderDraftStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    Order? createdOrder,
  }) {
    return OrderDraftState(
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      supplierPhone: supplierPhone ?? this.supplierPhone,
      supplierAvatarUrl: supplierAvatarUrl ?? this.supplierAvatarUrl,
      items: items ?? this.items,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }
}

class OrderDraftNotifier extends StateNotifier<OrderDraftState> {
  final OrdersRepository _repository;
  final Ref _ref;

  OrderDraftNotifier(this._repository, this._ref)
      : super(const OrderDraftState());

  void reset() {
    state = const OrderDraftState();
  }

  void setSupplier(Supplier supplier) {
    state = state.copyWith(
      supplierId: supplier.id,
      supplierName: supplier.name,
      supplierPhone: supplier.phoneNumber,
      supplierAvatarUrl: supplier.avatarUrl,
    );
  }

  void addProduct(Product product) {
    if (state.hasProduct(product.id)) return; // method, not getter
    state = state.copyWith(
      items: [
        ...state.items,
        OrderDraftItem(
          productId: product.id,
          productName: product.name,
          productUnit: product.unit,
          quantity: 1.0,
          unitPrice: product.price ?? 0.0,
        ),
      ],
    );
  }

  void removeProduct(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void updateQuantity(String productId, double qty) {
    if (qty <= 0) return;
    state = state.copyWith(
      items: state.items.map((i) {
        return i.productId == productId ? i.copyWith(quantity: qty) : i;
      }).toList(),
    );
  }

  void updatePrice(String productId, double price) {
    state = state.copyWith(
      items: state.items.map((i) {
        return i.productId == productId ? i.copyWith(unitPrice: price) : i;
      }).toList(),
    );
  }

  /// Upsert: adds product if not present, then sets qty + price in one shot.
  void setItem({
    required String productId,
    required String productName,
    required String productUnit,
    required double quantity,
    required double unitPrice,
  }) {
    final exists = state.hasProduct(productId);
    if (!exists) {
      state = state.copyWith(
        items: [
          ...state.items,
          OrderDraftItem(
            productId: productId,
            productName: productName,
            productUnit: productUnit,
            quantity: quantity,
            unitPrice: unitPrice,
          ),
        ],
      );
    } else {
      state = state.copyWith(
        items: state.items.map((i) {
          return i.productId == productId
              ? i.copyWith(quantity: quantity, unitPrice: unitPrice)
              : i;
        }).toList(),
      );
    }
  }

  void removeItem(String productId) => removeProduct(productId);

  void setItems(List<OrderDraftItem> items) {
    state = state.copyWith(items: items);
  }

  void setNotes(String? notes) {
    final trimmed = notes?.trim();
    state = state.copyWith(notes: (trimmed == null || trimmed.isEmpty) ? null : trimmed);
  }

  /// Saves the order as a draft immediately (called when user taps Review).
  /// Subsequent actions (WhatsApp, PDF, Save Draft) reuse the already-created
  /// order via [createdOrder] — no duplicate creates.
  Future<bool> saveDraft() => createOrder();

  Future<bool> createOrder() async {
    if (!state.canReview) return false;

    state = state.copyWith(
      status: OrderDraftStatus.loading,
      errorMessage: null,
      fieldErrors: {},
    );

    try {
      final items = state.items.map((item) {
        return <String, dynamic>{
          'product_id': item.productId,
          'quantity': item.quantity,
          if (item.unitPrice > 0) 'unit_price': item.unitPrice,
        };
      }).toList();

      final order = await _repository.createOrder(
        supplierId: state.supplierId!,
        items: items,
        notes: state.notes,
      );

      state = state.copyWith(
        status: OrderDraftStatus.success,
        createdOrder: order,
      );

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
      status: OrderDraftStatus.error,
      errorMessage: fieldErrors.isEmpty ? errorMessage : null,
      fieldErrors: fieldErrors,
    );
  }
}

final orderDraftProvider =
    StateNotifierProvider<OrderDraftNotifier, OrderDraftState>((ref) {
  return OrderDraftNotifier(
    ref.read(ordersRepositoryProvider),
    ref,
  );
});

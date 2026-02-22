import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/products/domain/entities/product.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import 'sales_provider.dart';

/// A single cart line: product + quantity + price (editable).
class CartItem {
  final Product product;
  final double quantity;
  final double unitPrice; // defaults to product.price, editable

  const CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  CartItem copyWith({double? quantity, double? unitPrice}) => CartItem(
        product: product,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
      );

  double get totalPrice => quantity * unitPrice;
}

enum CartStatus { idle, submitting, success, error }

class CartState {
  final List<CartItem> items;
  final CartStatus status;
  final String? errorMessage;
  final Sale? lastSale; // set after successful confirm

  const CartState({
    this.items = const [],
    this.status = CartStatus.idle,
    this.errorMessage,
    this.lastSale,
  });

  double get totalAmount => items.fold(0, (sum, i) => sum + i.totalPrice);
  int get totalItemCount => items.length;
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    CartStatus? status,
    String? errorMessage,
    Sale? lastSale,
  }) =>
      CartState(
        items: items ?? this.items,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        lastSale: lastSale ?? this.lastSale,
      );
}

class CartNotifier extends StateNotifier<CartState> {
  final SalesRepository _repo;
  final Ref _ref;

  CartNotifier(this._repo, this._ref) : super(const CartState());

  void addProduct(Product product, {double? overridePrice}) {
    final existing = state.items.indexWhere((i) => i.product.id == product.id);
    if (existing >= 0) {
      // Already in cart — increment quantity by 1
      final updated = List<CartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + 1,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [
        ...state.items,
        CartItem(
          product: product,
          quantity: 1,
          unitPrice: overridePrice ?? product.price ?? 0.0,
        ),
      ]);
    }
  }

  void incrementQty(String productId) {
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final updated = List<CartItem>.from(state.items);
    updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
    state = state.copyWith(items: updated);
  }

  void decrementQty(String productId) {
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final item = state.items[idx];
    if (item.quantity <= 1) {
      removeItem(productId);
    } else {
      final updated = List<CartItem>.from(state.items);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity - 1);
      state = state.copyWith(items: updated);
    }
  }

  void updatePrice(String productId, double price) {
    final idx = state.items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final updated = List<CartItem>.from(state.items);
    updated[idx] = updated[idx].copyWith(unitPrice: price);
    state = state.copyWith(items: updated);
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void clearCart() {
    state = const CartState();
  }

  Future<Sale?> confirmSale({String? notes}) async {
    if (state.items.isEmpty) return null;
    if (state.items.any((i) => i.unitPrice <= 0)) {
      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: 'All items must have a price greater than zero',
      );
      return null;
    }
    state = state.copyWith(status: CartStatus.submitting, errorMessage: null);
    try {
      final items = state.items.map((i) => {
            'product_id': i.product.id,
            'quantity': i.quantity,
            'unit_price': i.unitPrice,
          }).toList();

      final sale = await _repo.createSale(items: items, notes: notes);

      // Prepend to history list
      _ref.read(salesProvider.notifier).prependSale(sale);
      // Refresh summary
      _ref.read(saleSummaryProvider.notifier).load();
      // Refresh stock counts and dashboard stats (RULE-009)
      _ref.read(productsProvider.notifier).refresh();
      _ref.read(dashboardProvider.notifier).loadDashboard();

      state = CartState(status: CartStatus.success, lastSale: sale);
      return sale;
    } catch (e) {
      final message = e.toString().contains('Insufficient stock')
          ? e.toString()
          : null;
      state = state.copyWith(status: CartStatus.error, errorMessage: message);
      return null;
    }
  }

  void resetStatus() {
    state = state.copyWith(status: CartStatus.idle, errorMessage: null);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref.read(salesRepositoryProvider), ref);
});

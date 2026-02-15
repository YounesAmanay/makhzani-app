/// Product Form Provider
///
/// Riverpod provider for product CRUD operations.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import 'products_provider.dart';

enum ProductFormStatus { initial, loading, success, error }

class ProductFormState {
  final ProductFormStatus status;
  final Product? product;
  final String? errorMessage;

  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.product,
    this.errorMessage,
  });

  ProductFormState copyWith({
    ProductFormStatus? status,
    Product? product,
    String? errorMessage,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final ProductsRepository _repository;
  final Ref _ref;

  ProductFormNotifier(this._repository, this._ref)
      : super(const ProductFormState());

  void reset() {
    state = const ProductFormState();
  }

  Future<bool> createProduct({
    required String name,
    required int currentStock,
    required int reorderThreshold,
    required String unit,
    String? barcode,
    double? price,
  }) async {
    state = state.copyWith(status: ProductFormStatus.loading, errorMessage: null);

    try {
      final product = await _repository.createProduct(
        name: name,
        currentStock: currentStock,
        reorderThreshold: reorderThreshold,
        unit: unit,
        barcode: barcode,
        price: price,
      );

      state = state.copyWith(
        status: ProductFormStatus.success,
        product: product,
      );

      // Refresh products list
      _ref.read(productsProvider.notifier).refresh();

      return true;
    } catch (e) {
      String errorMessage = 'Failed to create product';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    String? name,
    int? currentStock,
    int? reorderThreshold,
    String? unit,
    String? barcode,
    double? price,
  }) async {
    state = state.copyWith(status: ProductFormStatus.loading, errorMessage: null);

    try {
      final product = await _repository.updateProduct(
        id: id,
        name: name,
        currentStock: currentStock,
        reorderThreshold: reorderThreshold,
        unit: unit,
        barcode: barcode,
        price: price,
      );

      state = state.copyWith(
        status: ProductFormStatus.success,
        product: product,
      );

      // Update in products list
      _ref.read(productsProvider.notifier).updateProductInList(product);

      return true;
    } catch (e) {
      String errorMessage = 'Failed to update product';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(status: ProductFormStatus.loading, errorMessage: null);

    try {
      await _repository.deleteProduct(id);

      state = state.copyWith(status: ProductFormStatus.success);

      // Remove from products list
      _ref.read(productsProvider.notifier).removeProductFromList(id);

      return true;
    } catch (e) {
      String errorMessage = 'Failed to delete product';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<bool> adjustStock({
    required String id,
    required int adjustment,
    String? reason,
  }) async {
    state = state.copyWith(status: ProductFormStatus.loading, errorMessage: null);

    try {
      final product = await _repository.adjustStock(
        id: id,
        adjustment: adjustment,
        reason: reason,
      );

      state = state.copyWith(
        status: ProductFormStatus.success,
        product: product,
      );

      // Update in products list
      _ref.read(productsProvider.notifier).updateProductInList(product);

      return true;
    } catch (e) {
      String errorMessage = 'Failed to adjust stock';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  Future<Product?> getProductById(String id) async {
    state = state.copyWith(status: ProductFormStatus.loading, errorMessage: null);

    try {
      final product = await _repository.getProductById(id);
      state = state.copyWith(
        status: ProductFormStatus.success,
        product: product,
      );
      return product;
    } catch (e) {
      String errorMessage = 'Failed to load product';
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          errorMessage = data['message'] ?? errorMessage;
        }
      }
      state = state.copyWith(
        status: ProductFormStatus.error,
        errorMessage: errorMessage,
      );
      return null;
    }
  }
}

final productFormProvider =
    StateNotifierProvider<ProductFormNotifier, ProductFormState>((ref) {
  return ProductFormNotifier(
    ref.read(productsRepositoryProvider),
    ref,
  );
});

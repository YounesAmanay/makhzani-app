/// Product Form Provider
///
/// Riverpod provider for product CRUD operations.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import 'products_provider.dart';

enum ProductFormStatus { initial, loading, success, error }

class ProductFormState {
  final ProductFormStatus status;
  final Product? product;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.product,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  ProductFormState copyWith({
    ProductFormStatus? status,
    Product? product,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      product: product ?? this.product,
      errorMessage: errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
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
    state = state.copyWith(
      status: ProductFormStatus.loading,
      errorMessage: null,
      fieldErrors: {},
    );

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

      // Refresh products list and dashboard stats
      _ref.read(productsProvider.notifier).refresh();
      _ref.read(dashboardProvider.notifier).refresh();

      return true;
    } catch (e) {
      String errorMessage = 'Failed to create product';
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
        status: ProductFormStatus.error,
        errorMessage: fieldErrors.isEmpty ? errorMessage : null,
        fieldErrors: fieldErrors,
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
    state = state.copyWith(
      status: ProductFormStatus.loading,
      errorMessage: null,
      fieldErrors: {},
    );

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

      // Update in products list and refresh dashboard (low_stock_count may change)
      _ref.read(productsProvider.notifier).updateProductInList(product);
      _ref.read(dashboardProvider.notifier).refresh();

      return true;
    } catch (e) {
      String errorMessage = 'Failed to update product';
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
        status: ProductFormStatus.error,
        errorMessage: fieldErrors.isEmpty ? errorMessage : null,
        fieldErrors: fieldErrors,
      );
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(status: ProductFormStatus.loading, errorMessage: null);

    try {
      await _repository.deleteProduct(id);

      state = state.copyWith(status: ProductFormStatus.success);

      // Remove from products list and refresh dashboard stats
      _ref.read(productsProvider.notifier).removeProductFromList(id);
      _ref.read(dashboardProvider.notifier).refresh();

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
      await _repository.adjustStock(
        id: id,
        adjustment: adjustment,
        reason: reason,
      );

      state = state.copyWith(status: ProductFormStatus.success);

      // Refresh products list and dashboard (low_stock_count may change)
      _ref.read(productsProvider.notifier).refresh();
      _ref.read(dashboardProvider.notifier).refresh();

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

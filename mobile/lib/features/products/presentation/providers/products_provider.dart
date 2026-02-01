/// Products Provider
///
/// Riverpod provider for products list state management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/products_repository.dart';

enum ProductsStatus { initial, loading, loaded, loadingMore, error }

class ProductsState {
  final ProductsStatus status;
  final List<Product> products;
  final Pagination? pagination;
  final String? search;
  final bool lowStockFilter;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.pagination,
    this.search,
    this.lowStockFilter = false,
    this.errorMessage,
  });

  bool get hasMore => pagination?.hasNextPage ?? false;
  int get currentPage => pagination?.currentPage ?? 1;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    Pagination? pagination,
    String? search,
    bool? lowStockFilter,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      pagination: pagination ?? this.pagination,
      search: search ?? this.search,
      lowStockFilter: lowStockFilter ?? this.lowStockFilter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsRepository _repository;

  ProductsNotifier(this._repository) : super(const ProductsState());

  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        status: ProductsStatus.loading,
        errorMessage: null,
      );
    } else if (state.status == ProductsStatus.initial) {
      state = state.copyWith(status: ProductsStatus.loading);
    }

    try {
      final result = await _repository.getProducts(
        page: 1,
        search: state.search,
        lowStock: state.lowStockFilter ? true : null,
      );

      state = state.copyWith(
        status: ProductsStatus.loaded,
        products: result.products,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductsStatus.error,
        errorMessage: 'Failed to load products',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ProductsStatus.loadingMore) {
      return;
    }

    state = state.copyWith(status: ProductsStatus.loadingMore);

    try {
      final result = await _repository.getProducts(
        page: state.currentPage + 1,
        search: state.search,
        lowStock: state.lowStockFilter ? true : null,
      );

      state = state.copyWith(
        status: ProductsStatus.loaded,
        products: [...state.products, ...result.products],
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProductsStatus.loaded,
        errorMessage: 'Failed to load more products',
      );
    }
  }

  Future<void> search(String? query) async {
    final trimmedQuery = query?.trim();
    if (trimmedQuery == state.search) return;

    state = state.copyWith(
      search: trimmedQuery?.isEmpty == true ? null : trimmedQuery,
      status: ProductsStatus.loading,
    );

    await loadProducts(refresh: true);
  }

  Future<void> toggleLowStockFilter() async {
    state = state.copyWith(
      lowStockFilter: !state.lowStockFilter,
      status: ProductsStatus.loading,
    );

    await loadProducts(refresh: true);
  }

  void setLowStockFilter(bool value) {
    if (value == state.lowStockFilter) return;
    state = state.copyWith(
      lowStockFilter: value,
      status: ProductsStatus.loading,
    );
    loadProducts(refresh: true);
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }

  void updateProductInList(Product updatedProduct) {
    final index = state.products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      final newProducts = List<Product>.from(state.products);
      newProducts[index] = updatedProduct;
      state = state.copyWith(products: newProducts);
    }
  }

  void removeProductFromList(String productId) {
    final newProducts = state.products.where((p) => p.id != productId).toList();
    state = state.copyWith(products: newProducts);
  }
}

// Providers
final productsRemoteDataSourceProvider =
    Provider<ProductsRemoteDataSource>((ref) {
  return ProductsRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.read(productsRemoteDataSourceProvider));
});

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(ref.read(productsRepositoryProvider));
});

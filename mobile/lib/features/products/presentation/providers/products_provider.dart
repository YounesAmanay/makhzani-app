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

enum ProductSort {
  nameAsc,
  nameDesc,
  stockLow,
  stockHigh,
  priceLow,
  priceHigh,
  newest,
}

class ProductsState {
  final ProductsStatus status;
  final List<Product> products;
  final Pagination? pagination;
  final String? search;
  final bool lowStockFilter;
  final ProductSort sortBy;
  final String? errorMessage;

  const ProductsState({
    this.status = ProductsStatus.initial,
    this.products = const [],
    this.pagination,
    this.search,
    this.lowStockFilter = false,
    this.sortBy = ProductSort.nameAsc,
    this.errorMessage,
  });

  bool get hasMore => pagination?.hasNextPage ?? false;
  int get currentPage => pagination?.currentPage ?? 1;
  bool get hasActiveFilters => lowStockFilter || search != null;

  ProductsState copyWith({
    ProductsStatus? status,
    List<Product>? products,
    Pagination? pagination,
    String? search,
    bool? lowStockFilter,
    ProductSort? sortBy,
    String? errorMessage,
  }) {
    return ProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      pagination: pagination ?? this.pagination,
      search: search ?? this.search,
      lowStockFilter: lowStockFilter ?? this.lowStockFilter,
      sortBy: sortBy ?? this.sortBy,
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
        products: _applySorting(result.products, state.sortBy),
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
        products: _applySorting(
          [...state.products, ...result.products],
          state.sortBy,
        ),
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

  void setSortBy(ProductSort sort) {
    if (sort == state.sortBy) return;
    state = state.copyWith(
      sortBy: sort,
      products: _applySorting(state.products, sort),
    );
  }

  List<Product> _applySorting(List<Product> products, ProductSort sort) {
    final sorted = List<Product>.from(products);
    switch (sort) {
      case ProductSort.nameAsc:
        sorted.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      case ProductSort.nameDesc:
        sorted.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      case ProductSort.stockLow:
        sorted.sort((a, b) => a.currentStock.compareTo(b.currentStock));
      case ProductSort.stockHigh:
        sorted.sort((a, b) => b.currentStock.compareTo(a.currentStock));
      case ProductSort.priceLow:
        sorted.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
      case ProductSort.priceHigh:
        sorted.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
      case ProductSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  Future<void> refresh() async {
    await loadProducts(refresh: true);
  }

  void updateProductInList(Product updatedProduct) {
    final index = state.products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      final newProducts = List<Product>.from(state.products);
      newProducts[index] = updatedProduct;
      state = state.copyWith(
        products: _applySorting(newProducts, state.sortBy),
      );
    }
  }

  void removeProductFromList(String productId) {
    final newProducts =
        state.products.where((p) => p.id != productId).toList();
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

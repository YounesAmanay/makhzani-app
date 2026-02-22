/// Categories Provider
///
/// Manages fetching and CRUD operations for product categories.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/category_model.dart';
import '../../domain/entities/category.dart';

enum CategoriesStatus { initial, loading, loaded, error }

class CategoriesState {
  final List<Category> categories;
  final CategoriesStatus status;
  final String? errorMessage;

  const CategoriesState({
    this.categories = const [],
    this.status = CategoriesStatus.initial,
    this.errorMessage,
  });

  CategoriesState copyWith({
    List<Category>? categories,
    CategoriesStatus? status,
    String? errorMessage,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final ApiClient _apiClient;

  CategoriesNotifier(this._apiClient) : super(const CategoriesState());

  Future<void> loadCategories() async {
    if (state.status == CategoriesStatus.loading) return;
    state = state.copyWith(status: CategoriesStatus.loading);
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);
      final data = response.data['data'] as Map<String, dynamic>;
      final list = (data['categories'] as List)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList();
      state = state.copyWith(status: CategoriesStatus.loaded, categories: list);
    } catch (e) {
      state = state.copyWith(
        status: CategoriesStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<Category?> createCategory(String name, {String? color, String? icon}) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.categories, data: {
        'name': name,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
      });
      final category = CategoryModel.fromJson(
        response.data['data']['category'] as Map<String, dynamic>,
      ).toEntity();
      state = state.copyWith(categories: [...state.categories, category]);
      return category;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.categoryById(id));
      state = state.copyWith(
        categories: state.categories.where((c) => c.id != id).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Seeds the 22 default Moroccan categories for this merchant.
  /// Idempotent — existing categories are skipped.
  /// Returns { created, skipped } or null on error.
  Future<({int created, int skipped})?> seedDefaults() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.categoriesSeedDefaults);
      final data = response.data['data'] as Map<String, dynamic>;
      final created = data['created'] as int;
      final skipped = data['skipped'] as int;
      // Reload the full list to reflect the newly created categories
      await loadCategories();
      return (created: created, skipped: skipped);
    } catch (_) {
      return null;
    }
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  return CategoriesNotifier(ref.read(apiClientProvider));
});

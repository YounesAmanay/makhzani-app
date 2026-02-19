/// Suppliers Provider
///
/// Riverpod provider for suppliers list state management.
/// Search and city filter are server-side.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/suppliers_remote_datasource.dart';
import '../../data/repositories/suppliers_repository_impl.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/suppliers_repository.dart';

const _sentinel = Object();

enum SuppliersStatus { initial, loading, loaded, error }

class SuppliersState {
  final SuppliersStatus status;
  final List<Supplier> allSuppliers;
  final String? search;
  final String? city;
  final String? errorMessage;

  const SuppliersState({
    this.status = SuppliersStatus.initial,
    this.allSuppliers = const [],
    this.search,
    this.city,
    this.errorMessage,
  });

  bool get hasActiveFilters => search != null || city != null;

  // Server returns already-filtered results; expose directly
  List<Supplier> get filteredSuppliers => allSuppliers;

  SuppliersState copyWith({
    SuppliersStatus? status,
    List<Supplier>? allSuppliers,
    Object? search = _sentinel,
    Object? city = _sentinel,
    String? errorMessage,
  }) {
    return SuppliersState(
      status: status ?? this.status,
      allSuppliers: allSuppliers ?? this.allSuppliers,
      search: search == _sentinel ? this.search : search as String?,
      city: city == _sentinel ? this.city : city as String?,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SuppliersNotifier extends StateNotifier<SuppliersState> {
  final SuppliersRepository _repository;

  SuppliersNotifier(this._repository) : super(const SuppliersState());

  Future<void> loadSuppliers() async {
    state = state.copyWith(
      status: SuppliersStatus.loading,
      errorMessage: null,
    );

    try {
      final suppliers = await _repository.getSuppliers(
        search: state.search,
        city: state.city,
      );
      state = state.copyWith(
        status: SuppliersStatus.loaded,
        allSuppliers: suppliers,
      );
    } catch (e) {
      state = state.copyWith(
        status: SuppliersStatus.error,
        errorMessage: 'Failed to load suppliers',
      );
    }
  }

  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    final newSearch = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    if (newSearch == state.search) return;
    state = state.copyWith(
      search: newSearch,
      status: SuppliersStatus.loading,
    );
    await loadSuppliers();
  }

  Future<void> filterByCity(String? city) async {
    if (city == state.city) return;
    state = state.copyWith(
      city: city,
      status: SuppliersStatus.loading,
    );
    await loadSuppliers();
  }

  Future<void> refresh() async {
    await loadSuppliers();
  }

  void removeSupplierFromList(String supplierId) {
    final updated =
        state.allSuppliers.where((s) => s.id != supplierId).toList();
    state = state.copyWith(allSuppliers: updated);
  }
}

// Providers
final suppliersRemoteDataSourceProvider =
    Provider<SuppliersRemoteDataSource>((ref) {
  return SuppliersRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepositoryImpl(ref.read(suppliersRemoteDataSourceProvider));
});

final suppliersProvider =
    StateNotifierProvider<SuppliersNotifier, SuppliersState>((ref) {
  return SuppliersNotifier(ref.read(suppliersRepositoryProvider));
});

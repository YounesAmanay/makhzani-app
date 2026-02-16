/// Suppliers Provider
///
/// Riverpod provider for suppliers list state management.
/// Backend returns all suppliers at once (no server pagination/search),
/// so filtering is done client-side.
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
  final String? errorMessage;

  const SuppliersState({
    this.status = SuppliersStatus.initial,
    this.allSuppliers = const [],
    this.search,
    this.errorMessage,
  });

  bool get hasActiveFilters => search != null;

  List<Supplier> get filteredSuppliers {
    if (search == null || search!.isEmpty) return allSuppliers;

    final query = search!.toLowerCase();
    return allSuppliers.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.phoneNumber.contains(query) ||
          (s.businessName?.toLowerCase().contains(query) ?? false) ||
          (s.city?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  SuppliersState copyWith({
    SuppliersStatus? status,
    List<Supplier>? allSuppliers,
    Object? search = _sentinel,
    String? errorMessage,
  }) {
    return SuppliersState(
      status: status ?? this.status,
      allSuppliers: allSuppliers ?? this.allSuppliers,
      search: search == _sentinel ? this.search : search as String?,
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
      final suppliers = await _repository.getSuppliers();
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

  void search(String? query) {
    final trimmed = query?.trim();
    state = state.copyWith(
      search: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
    );
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

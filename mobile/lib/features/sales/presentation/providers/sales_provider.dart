import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/sales_remote_datasource.dart';
import '../../data/repositories/sales_repository_impl.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_summary.dart';
import '../../domain/repositories/sales_repository.dart';

// ─── Infrastructure providers ────────────────────────────────────────────────

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SalesRepositoryImpl(SalesRemoteDatasource(apiClient));
});

// ─── Sales history ────────────────────────────────────────────────────────────

enum SalesStatus { initial, loading, loaded, error }

class SalesState {
  final List<Sale> sales;
  final SalesStatus status;
  final String? errorMessage;
  final bool hasMore;
  final int page;

  const SalesState({
    this.sales = const [],
    this.status = SalesStatus.initial,
    this.errorMessage,
    this.hasMore = true,
    this.page = 1,
  });

  SalesState copyWith({
    List<Sale>? sales,
    SalesStatus? status,
    String? errorMessage,
    bool? hasMore,
    int? page,
  }) =>
      SalesState(
        sales: sales ?? this.sales,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
      );
}

class SalesNotifier extends StateNotifier<SalesState> {
  final SalesRepository _repo;

  SalesNotifier(this._repo) : super(const SalesState());

  Future<void> load() async {
    state = state.copyWith(status: SalesStatus.loading, sales: [], page: 1, hasMore: true);
    try {
      final sales = await _repo.getSales(page: 1);
      state = state.copyWith(
        status: SalesStatus.loaded,
        sales: sales,
        page: 1,
        hasMore: sales.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(status: SalesStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == SalesStatus.loading) return;
    try {
      final nextPage = state.page + 1;
      final more = await _repo.getSales(page: nextPage);
      state = state.copyWith(
        sales: [...state.sales, ...more],
        page: nextPage,
        hasMore: more.length >= 20,
      );
    } catch (_) {}
  }

  Future<void> refresh() => load();

  /// Called after a new sale is confirmed — prepend to list without full reload.
  void prependSale(Sale sale) {
    state = state.copyWith(sales: [sale, ...state.sales]);
  }

  Future<void> cancelSale(String id) async {
    await _repo.cancelSale(id);
    state = state.copyWith(sales: state.sales.where((s) => s.id != id).toList());
  }
}

final salesProvider = StateNotifierProvider<SalesNotifier, SalesState>((ref) {
  return SalesNotifier(ref.read(salesRepositoryProvider));
});

// ─── Sales summary ────────────────────────────────────────────────────────────

class SaleSummaryState {
  final SaleSummary? summary;
  final bool isLoading;

  const SaleSummaryState({this.summary, this.isLoading = false});

  SaleSummaryState copyWith({SaleSummary? summary, bool? isLoading}) =>
      SaleSummaryState(summary: summary ?? this.summary, isLoading: isLoading ?? this.isLoading);
}

class SaleSummaryNotifier extends StateNotifier<SaleSummaryState> {
  final SalesRepository _repo;

  SaleSummaryNotifier(this._repo) : super(const SaleSummaryState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final summary = await _repo.getSummary();
      state = SaleSummaryState(summary: summary, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final saleSummaryProvider = StateNotifierProvider<SaleSummaryNotifier, SaleSummaryState>((ref) {
  return SaleSummaryNotifier(ref.read(salesRepositoryProvider));
});

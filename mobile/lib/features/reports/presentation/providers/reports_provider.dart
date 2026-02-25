import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/reports_remote_datasource.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/entities/sales_report.dart';
import '../../domain/entities/products_report.dart';
import '../../domain/entities/inventory_report.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ReportsRepository(ReportsRemoteDatasource(apiClient));
});

// ─── Shared status ────────────────────────────────────────────────────────────

enum ReportStatus { initial, loading, loaded, error }

// ─── Sales Report ─────────────────────────────────────────────────────────────

class SalesReportState {
  final ReportStatus status;
  final SalesReport? report;
  final String selectedPeriod;
  final String? errorMessage;

  const SalesReportState({
    this.status = ReportStatus.initial,
    this.report,
    this.selectedPeriod = 'month',
    this.errorMessage,
  });

  SalesReportState copyWith({
    ReportStatus? status,
    SalesReport? report,
    String? selectedPeriod,
    String? errorMessage,
  }) =>
      SalesReportState(
        status: status ?? this.status,
        report: report ?? this.report,
        selectedPeriod: selectedPeriod ?? this.selectedPeriod,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class SalesReportNotifier extends StateNotifier<SalesReportState> {
  final ReportsRepository _repo;

  SalesReportNotifier(this._repo) : super(const SalesReportState());

  Future<void> load({String? period}) async {
    final p = period ?? state.selectedPeriod;
    state = state.copyWith(status: ReportStatus.loading, selectedPeriod: p);
    try {
      final report = await _repo.getSalesReport(period: p);
      state = state.copyWith(status: ReportStatus.loaded, report: report);
    } catch (e) {
      state = state.copyWith(status: ReportStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> loadCustom({required String from, required String to}) async {
    state = state.copyWith(status: ReportStatus.loading, selectedPeriod: 'custom');
    try {
      final report = await _repo.getSalesReport(period: 'custom', from: from, to: to);
      state = state.copyWith(status: ReportStatus.loaded, report: report);
    } catch (e) {
      state = state.copyWith(status: ReportStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final salesReportProvider =
    StateNotifierProvider<SalesReportNotifier, SalesReportState>((ref) {
  return SalesReportNotifier(ref.read(reportsRepositoryProvider));
});

// ─── Products Report ──────────────────────────────────────────────────────────

class ProductsReportState {
  final ReportStatus status;
  final ProductsReport? report;
  final String? errorMessage;

  const ProductsReportState({
    this.status = ReportStatus.initial,
    this.report,
    this.errorMessage,
  });

  ProductsReportState copyWith({
    ReportStatus? status,
    ProductsReport? report,
    String? errorMessage,
  }) =>
      ProductsReportState(
        status: status ?? this.status,
        report: report ?? this.report,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class ProductsReportNotifier extends StateNotifier<ProductsReportState> {
  final ReportsRepository _repo;

  ProductsReportNotifier(this._repo) : super(const ProductsReportState());

  Future<void> load() async {
    state = state.copyWith(status: ReportStatus.loading);
    try {
      final report = await _repo.getProductsReport();
      state = state.copyWith(status: ReportStatus.loaded, report: report);
    } catch (e) {
      state = state.copyWith(status: ReportStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final productsReportProvider =
    StateNotifierProvider<ProductsReportNotifier, ProductsReportState>((ref) {
  return ProductsReportNotifier(ref.read(reportsRepositoryProvider));
});

// ─── Inventory Report ─────────────────────────────────────────────────────────

class InventoryReportState {
  final ReportStatus status;
  final InventoryReport? report;
  final String? errorMessage;

  const InventoryReportState({
    this.status = ReportStatus.initial,
    this.report,
    this.errorMessage,
  });

  InventoryReportState copyWith({
    ReportStatus? status,
    InventoryReport? report,
    String? errorMessage,
  }) =>
      InventoryReportState(
        status: status ?? this.status,
        report: report ?? this.report,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class InventoryReportNotifier extends StateNotifier<InventoryReportState> {
  final ReportsRepository _repo;

  InventoryReportNotifier(this._repo) : super(const InventoryReportState());

  Future<void> load() async {
    state = state.copyWith(status: ReportStatus.loading);
    try {
      final report = await _repo.getInventoryReport();
      state = state.copyWith(status: ReportStatus.loaded, report: report);
    } catch (e) {
      state = state.copyWith(status: ReportStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final inventoryReportProvider =
    StateNotifierProvider<InventoryReportNotifier, InventoryReportState>((ref) {
  return InventoryReportNotifier(ref.read(reportsRepositoryProvider));
});

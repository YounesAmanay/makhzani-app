/// Dashboard Provider
///
/// Riverpod provider for dashboard state management.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/low_stock_item.dart';
import '../../domain/entities/recent_order.dart';
import '../../domain/entities/sales_chart_point.dart';
import '../../domain/entities/top_selling_product.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardState {
  final DashboardStatus status;
  final DashboardStats? stats;
  final List<LowStockItem> lowStockItems;
  final List<RecentOrder> recentOrders;
  final List<SalesChartPoint> chartData;
  final List<TopSellingProduct> topSelling;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.stats,
    this.lowStockItems = const [],
    this.recentOrders = const [],
    this.chartData = const [],
    this.topSelling = const [],
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardStats? stats,
    List<LowStockItem>? lowStockItems,
    List<RecentOrder>? recentOrders,
    List<SalesChartPoint>? chartData,
    List<TopSellingProduct>? topSelling,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      recentOrders: recentOrders ?? this.recentOrders,
      chartData: chartData ?? this.chartData,
      topSelling: topSelling ?? this.topSelling,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardNotifier(this._remoteDataSource) : super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(status: DashboardStatus.loading, errorMessage: null);

    try {
      final result = await _remoteDataSource.getDashboardData();

      state = state.copyWith(
        status: DashboardStatus.loaded,
        stats: result.stats.toEntity(),
        lowStockItems: result.lowStockItems.map((m) => m.toEntity()).toList(),
        recentOrders: result.recentOrders.map((m) => m.toEntity()).toList(),
        chartData: result.chartData.map((m) => m.toEntity()).toList(),
        topSelling: result.topSelling.map((m) => m.toEntity()).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        status: DashboardStatus.error,
        errorMessage: 'Failed to load dashboard',
      );
    }
  }

  Future<void> refresh() async {
    await loadDashboard();
  }
}

// Providers
final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.read(dashboardRemoteDataSourceProvider));
});

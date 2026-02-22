/// Dashboard Remote Data Source
///
/// Handles API calls for dashboard data.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/dashboard_stats_model.dart';
import '../models/low_stock_item_model.dart';
import '../models/recent_order_model.dart';
import '../models/sales_chart_point_model.dart';
import '../models/top_selling_product_model.dart';

abstract class DashboardRemoteDataSource {
  Future<
      ({
        DashboardStatsModel stats,
        List<LowStockItemModel> lowStockItems,
        List<RecentOrderModel> recentOrders,
        List<SalesChartPointModel> chartData,
        List<TopSellingProductModel> topSelling,
      })> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  DashboardRemoteDataSourceImpl(this._apiClient);

  @override
  Future<
      ({
        DashboardStatsModel stats,
        List<LowStockItemModel> lowStockItems,
        List<RecentOrderModel> recentOrders,
        List<SalesChartPointModel> chartData,
        List<TopSellingProductModel> topSelling,
      })> getDashboardData() async {
    final response = await _apiClient.get(ApiEndpoints.dashboardStats);

    final data = response.data['data'];

    final stats = DashboardStatsModel.fromJson(data['overview']);

    final lowStockItems = (data['low_stock_items'] as List)
        .map((item) => LowStockItemModel.fromJson(item))
        .toList();

    final recentOrders = (data['recent_orders'] as List)
        .map((order) => RecentOrderModel.fromJson(order))
        .toList();

    final chartData = (data['chart_data'] as List)
        .map((point) => SalesChartPointModel.fromJson(point))
        .toList();

    final topSelling = (data['top_selling_products'] as List)
        .map((p) => TopSellingProductModel.fromJson(p))
        .toList();

    return (
      stats: stats,
      lowStockItems: lowStockItems,
      recentOrders: recentOrders,
      chartData: chartData,
      topSelling: topSelling,
    );
  }
}

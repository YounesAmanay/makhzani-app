/// Dashboard Stats Model (Data Layer)
///
/// JSON serialization for dashboard statistics from API.
library;

import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel {
  final int totalProducts;
  final int lowStockProducts;
  final int totalSuppliers;
  final int totalOrders;
  final double profitThisMonth;
  final double profitTotal;
  final double stockValue;

  const DashboardStatsModel({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalSuppliers,
    required this.totalOrders,
    this.profitThisMonth = 0,
    this.profitTotal = 0,
    this.stockValue = 0,
  });

  /// [data] is the full `data` object from the API response.
  /// Overview counts live in data['overview']; profit/stock_value at data level.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> data) {
    final overview = data['overview'] as Map<String, dynamic>? ?? data;
    final profit = data['profit'] as Map<String, dynamic>?;
    return DashboardStatsModel(
      totalProducts: overview['total_products'] ?? 0,
      lowStockProducts: overview['low_stock_products'] ?? 0,
      totalSuppliers: overview['total_suppliers'] ?? 0,
      totalOrders: overview['total_orders'] ?? 0,
      profitThisMonth: double.parse((profit?['this_month'] ?? 0).toString()),
      profitTotal: double.parse((profit?['total'] ?? 0).toString()),
      stockValue: double.parse((data['stock_value'] ?? 0).toString()),
    );
  }

  DashboardStats toEntity() => DashboardStats(
    totalProducts: totalProducts,
    lowStockProducts: lowStockProducts,
    totalSuppliers: totalSuppliers,
    totalOrders: totalOrders,
    profitThisMonth: profitThisMonth,
    profitTotal: profitTotal,
    stockValue: stockValue,
  );
}

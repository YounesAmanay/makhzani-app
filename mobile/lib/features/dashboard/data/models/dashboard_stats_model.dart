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

  const DashboardStatsModel({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalSuppliers,
    required this.totalOrders,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalProducts: json['total_products'] ?? 0,
      lowStockProducts: json['low_stock_products'] ?? 0,
      totalSuppliers: json['total_suppliers'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
    );
  }

  DashboardStats toEntity() => DashboardStats(
    totalProducts: totalProducts,
    lowStockProducts: lowStockProducts,
    totalSuppliers: totalSuppliers,
    totalOrders: totalOrders,
  );
}

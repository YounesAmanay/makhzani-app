import '../../domain/entities/inventory_report.dart';

class InventoryReportModel {
  factory InventoryReportModel.fromJson(Map<String, dynamic> json) {
    final byCategory = (json['by_category'] as List<dynamic>)
        .map((e) => _parseCategoryStock(e as Map<String, dynamic>))
        .toList();

    return InventoryReportModel._(InventoryReport(
      totalProducts: (json['total_products'] as num).toInt(),
      healthyStock: (json['healthy_stock'] as num).toInt(),
      lowStock: (json['low_stock'] as num).toInt(),
      zeroStock: (json['zero_stock'] as num).toInt(),
      totalStockValue: (json['total_stock_value'] as num).toDouble(),
      reorderImpact: (json['reorder_impact'] as num).toDouble(),
      healthScore: (json['health_score'] as num).toInt(),
      byCategory: byCategory,
    ));
  }

  static CategoryStock _parseCategoryStock(Map<String, dynamic> m) => CategoryStock(
        categoryId: m['category_id'].toString(),
        name: m['name'] as String,
        stockValue: (m['stock_value'] as num).toDouble(),
        productCount: (m['product_count'] as num).toInt(),
        lowStockCount: (m['low_stock_count'] as num).toInt(),
      );

  InventoryReportModel._(this._entity);
  final InventoryReport _entity;

  InventoryReport toEntity() => _entity;
}

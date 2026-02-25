import '../../domain/entities/products_report.dart';

class ProductsReportModel {
  factory ProductsReportModel.fromJson(Map<String, dynamic> json) {
    final bestSellers = (json['best_sellers'] as List<dynamic>)
        .map((e) => _parseBestSeller(e as Map<String, dynamic>))
        .toList();

    final deadStock = (json['dead_stock'] as List<dynamic>)
        .map((e) => _parseDeadStock(e as Map<String, dynamic>))
        .toList();

    final byCategory = (json['by_category'] as List<dynamic>)
        .map((e) => _parseCategoryRevenue(e as Map<String, dynamic>))
        .toList();

    return ProductsReportModel._(ProductsReport(
      bestSellers: bestSellers,
      deadStock: deadStock,
      byCategory: byCategory,
    ));
  }

  static BestSeller _parseBestSeller(Map<String, dynamic> m) => BestSeller(
        productId: m['product_id'] as String,
        name: m['name'] as String,
        revenue: (m['revenue'] as num).toDouble(),
        quantitySold: (m['quantity_sold'] as num).toDouble(),
        profit: (m['profit'] as num).toDouble(),
        marginPct: (m['margin_pct'] as num).toDouble(),
      );

  static DeadStockItem _parseDeadStock(Map<String, dynamic> m) => DeadStockItem(
        productId: m['product_id'] as String,
        name: m['name'] as String,
        currentStock: (m['current_stock'] as num).toInt(),
        unit: m['unit'] as String? ?? '',
        stockValue: (m['stock_value'] as num).toDouble(),
        daysSinceLastSale: m['days_since_last_sale'] != null
            ? (m['days_since_last_sale'] as num).toInt()
            : null,
      );

  static CategoryRevenue _parseCategoryRevenue(Map<String, dynamic> m) => CategoryRevenue(
        categoryId: m['category_id'].toString(),
        name: m['name'] as String,
        revenue: (m['revenue'] as num).toDouble(),
        productCount: (m['product_count'] as num).toInt(),
      );

  ProductsReportModel._(this._entity);
  final ProductsReport _entity;

  ProductsReport toEntity() => _entity;
}

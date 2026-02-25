import '../../domain/entities/sales_report.dart';

class SalesReportModel {
  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    final p = json['period'] as Map<String, dynamic>;
    final s = json['summary'] as Map<String, dynamic>;

    final period = SalesReportPeriod(
      from: p['from'] as String,
      to: p['to'] as String,
      label: p['label'] as String? ?? 'month',
    );

    final summary = SalesReportSummary(
      totalRevenue: (s['total_revenue'] as num).toDouble(),
      totalSales: (s['total_sales'] as num).toInt(),
      totalProfit: (s['total_profit'] as num).toDouble(),
      avgSaleValue: (s['avg_sale_value'] as num).toDouble(),
      cancelledCount: (s['cancelled_count'] as num).toInt(),
      cancelledValue: (s['cancelled_value'] as num).toDouble(),
    );

    final chart = (json['chart'] as List<dynamic>)
        .map((e) => _parseChartPoint(e as Map<String, dynamic>))
        .toList();

    final topProducts = (json['top_products'] as List<dynamic>)
        .map((e) => _parseTopProduct(e as Map<String, dynamic>))
        .toList();

    DayStat? parseDayStat(dynamic raw) {
      if (raw == null) return null;
      final m = raw as Map<String, dynamic>;
      return DayStat(
        date: m['date'] as String,
        revenue: (m['revenue'] as num).toDouble(),
      );
    }

    return SalesReportModel._(SalesReport(
      period: period,
      summary: summary,
      chart: chart,
      topProducts: topProducts,
      bestDay: parseDayStat(json['best_day']),
      worstDay: parseDayStat(json['worst_day']),
    ));
  }

  static SalesChartPoint _parseChartPoint(Map<String, dynamic> m) => SalesChartPoint(
        date: m['date'] as String,
        revenue: (m['revenue'] as num).toDouble(),
        count: (m['count'] as num).toInt(),
      );

  static TopProduct _parseTopProduct(Map<String, dynamic> m) => TopProduct(
        productId: m['product_id'] as String,
        name: m['name'] as String,
        revenue: (m['revenue'] as num).toDouble(),
        quantity: (m['quantity'] as num).toDouble(),
        profit: (m['profit'] as num).toDouble(),
      );

  SalesReportModel._(this._entity);
  final SalesReport _entity;

  SalesReport toEntity() => _entity;
}

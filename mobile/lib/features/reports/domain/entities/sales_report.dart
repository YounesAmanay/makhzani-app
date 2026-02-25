/// Sales Report entity — the seller's sales window.
class SalesReportPeriod {
  final String from;
  final String to;
  final String label;

  const SalesReportPeriod({
    required this.from,
    required this.to,
    required this.label,
  });
}

class SalesReportSummary {
  final double totalRevenue;
  final int totalSales;
  final double totalProfit;
  final double avgSaleValue;
  final int cancelledCount;
  final double cancelledValue;

  const SalesReportSummary({
    required this.totalRevenue,
    required this.totalSales,
    required this.totalProfit,
    required this.avgSaleValue,
    required this.cancelledCount,
    required this.cancelledValue,
  });
}

class SalesChartPoint {
  final String date;
  final double revenue;
  final int count;

  const SalesChartPoint({
    required this.date,
    required this.revenue,
    required this.count,
  });
}

class TopProduct {
  final String productId;
  final String name;
  final double revenue;
  final double quantity;
  final double profit;

  const TopProduct({
    required this.productId,
    required this.name,
    required this.revenue,
    required this.quantity,
    required this.profit,
  });
}

class DayStat {
  final String date;
  final double revenue;

  const DayStat({required this.date, required this.revenue});
}

class SalesReport {
  final SalesReportPeriod period;
  final SalesReportSummary summary;
  final List<SalesChartPoint> chart;
  final List<TopProduct> topProducts;
  final DayStat? bestDay;
  final DayStat? worstDay;

  const SalesReport({
    required this.period,
    required this.summary,
    required this.chart,
    required this.topProducts,
    this.bestDay,
    this.worstDay,
  });
}

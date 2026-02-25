/// Products Report entity — best sellers, dead stock, by category.
class BestSeller {
  final String productId;
  final String name;
  final double revenue;
  final double quantitySold;
  final double profit;
  final double marginPct;

  const BestSeller({
    required this.productId,
    required this.name,
    required this.revenue,
    required this.quantitySold,
    required this.profit,
    required this.marginPct,
  });
}

class DeadStockItem {
  final String productId;
  final String name;
  final int currentStock;
  final String unit;
  final double stockValue;
  final int? daysSinceLastSale;

  const DeadStockItem({
    required this.productId,
    required this.name,
    required this.currentStock,
    required this.unit,
    required this.stockValue,
    this.daysSinceLastSale,
  });
}

class CategoryRevenue {
  final String categoryId;
  final String name;
  final double revenue;
  final int productCount;

  const CategoryRevenue({
    required this.categoryId,
    required this.name,
    required this.revenue,
    required this.productCount,
  });
}

class ProductsReport {
  final List<BestSeller> bestSellers;
  final List<DeadStockItem> deadStock;
  final List<CategoryRevenue> byCategory;

  const ProductsReport({
    required this.bestSellers,
    required this.deadStock,
    required this.byCategory,
  });
}

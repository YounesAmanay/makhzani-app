/// Inventory Report entity — stock health overview.
class CategoryStock {
  final String categoryId;
  final String name;
  final double stockValue;
  final int productCount;
  final int lowStockCount;

  const CategoryStock({
    required this.categoryId,
    required this.name,
    required this.stockValue,
    required this.productCount,
    required this.lowStockCount,
  });
}

class InventoryReport {
  final int totalProducts;
  final int healthyStock;
  final int lowStock;
  final int zeroStock;
  final double totalStockValue;
  final double reorderImpact;
  final int healthScore;
  final List<CategoryStock> byCategory;

  const InventoryReport({
    required this.totalProducts,
    required this.healthyStock,
    required this.lowStock,
    required this.zeroStock,
    required this.totalStockValue,
    required this.reorderImpact,
    required this.healthScore,
    required this.byCategory,
  });
}

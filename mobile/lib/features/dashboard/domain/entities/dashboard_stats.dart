/// Dashboard Stats Entity
///
/// Represents the merchant's dashboard statistics.
library;

class DashboardStats {
  final int totalProducts;
  final int lowStockProducts;
  final int totalSuppliers;
  final int totalOrders;
  final double profitThisMonth;
  final double profitTotal;
  final double stockValue;

  const DashboardStats({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalSuppliers,
    required this.totalOrders,
    this.profitThisMonth = 0,
    this.profitTotal = 0,
    this.stockValue = 0,
  });
}

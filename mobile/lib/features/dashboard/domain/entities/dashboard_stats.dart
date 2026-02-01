/// Dashboard Stats Entity
///
/// Represents the merchant's dashboard statistics.
library;

class DashboardStats {
  final int totalProducts;
  final int lowStockProducts;
  final int totalSuppliers;
  final int totalOrders;

  const DashboardStats({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalSuppliers,
    required this.totalOrders,
  });
}

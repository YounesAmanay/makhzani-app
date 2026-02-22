class TopSellingProduct {
  final String productId;
  final String name;
  final String unit;
  final double totalSold;
  final double totalRevenue;

  const TopSellingProduct({
    required this.productId,
    required this.name,
    required this.unit,
    required this.totalSold,
    required this.totalRevenue,
  });
}

/// Low Stock Item Entity
///
/// Represents a product that is below reorder threshold.
library;

class LowStockItem {
  final String id;
  final String name;
  final int currentStock;
  final int reorderThreshold;
  final String unit;
  final int shortage;

  const LowStockItem({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.reorderThreshold,
    required this.unit,
    required this.shortage,
  });
}

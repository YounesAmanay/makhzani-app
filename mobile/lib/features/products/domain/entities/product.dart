/// Product Entity
library;

class Product {
  final String id;
  final String name;
  final int currentStock;
  final int reorderThreshold;
  final String unit;
  final String? barcode;
  final double? price;
  final bool needsReorder;
  final String stockStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.reorderThreshold,
    required this.unit,
    this.barcode,
    this.price,
    required this.needsReorder,
    required this.stockStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLowStock => needsReorder || currentStock <= reorderThreshold;
  bool get isOutOfStock => currentStock == 0;
}

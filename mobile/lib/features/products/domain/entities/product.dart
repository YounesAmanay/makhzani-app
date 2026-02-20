/// Product Entity
library;

class ProductImage {
  final String id;
  final String imageUrl;
  final bool isPrimary;

  const ProductImage({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
  });
}

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
  final List<ProductImage> images;

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
    this.images = const [],
  });

  bool get isLowStock => needsReorder || currentStock <= reorderThreshold;
  bool get isOutOfStock => currentStock == 0;
}

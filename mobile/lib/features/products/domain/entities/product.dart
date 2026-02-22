/// Product Entity
library;

import 'category.dart';

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
  final double? costPrice;
  final bool needsReorder;
  final String stockStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImage> images;
  final String? categoryId;
  final Category? category;

  const Product({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.reorderThreshold,
    required this.unit,
    this.barcode,
    this.price,
    this.costPrice,
    required this.needsReorder,
    required this.stockStatus,
    required this.createdAt,
    required this.updatedAt,
    this.images = const [],
    this.categoryId,
    this.category,
  });

  bool get isLowStock => needsReorder || currentStock <= reorderThreshold;
  bool get isOutOfStock => currentStock == 0;
  double? get margin => (price != null && costPrice != null && price! > 0)
      ? ((price! - costPrice!) / price! * 100)
      : null;
}

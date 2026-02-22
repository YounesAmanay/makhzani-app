/// Product Model
library;

import '../../domain/entities/product.dart';
import 'category_model.dart';

class ProductImageModel {
  final String id;
  final String imageUrl;
  final bool isPrimary;

  const ProductImageModel({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'],
      // Backend returns 'url' from the images table; accept both spellings
      imageUrl: (json['url'] ?? json['image_url']) as String,
      isPrimary: json['is_primary'] ?? false,
    );
  }

  ProductImage toEntity() => ProductImage(
    id: id,
    imageUrl: imageUrl,
    isPrimary: isPrimary,
  );
}

class ProductModel {
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
  final List<ProductImageModel> images;
  final String? categoryId;
  final CategoryModel? category;

  const ProductModel({
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
    this.categoryId,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      currentStock: json['current_stock'] ?? 0,
      reorderThreshold: json['reorder_threshold'] ?? 0,
      unit: json['unit'] ?? 'piece',
      barcode: json['barcode'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      needsReorder: json['needs_reorder'] ?? false,
      stockStatus: json['stock_status'] ?? 'ok',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.parse(json['created_at']),
      images: (json['images'] as List?)
              ?.map((img) => ProductImageModel.fromJson(img))
              .toList() ??
          [],
      categoryId: json['category_id'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'current_stock': currentStock,
      'reorder_threshold': reorderThreshold,
      'unit': unit,
      if (barcode != null) 'barcode': barcode,
      if (price != null) 'price': price,
      if (categoryId != null) 'category_id': categoryId,
    };
  }

  Product toEntity() => Product(
    id: id,
    name: name,
    currentStock: currentStock,
    reorderThreshold: reorderThreshold,
    unit: unit,
    barcode: barcode,
    price: price,
    needsReorder: needsReorder,
    stockStatus: stockStatus,
    createdAt: createdAt,
    updatedAt: updatedAt,
    images: images.map((img) => img.toEntity()).toList(),
    categoryId: categoryId,
    category: category?.toEntity(),
  );
}

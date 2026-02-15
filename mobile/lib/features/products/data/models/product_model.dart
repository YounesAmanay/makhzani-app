/// Product Model
library;

import '../../domain/entities/product.dart';

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
      updatedAt: DateTime.parse(json['updated_at']),
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
  );
}

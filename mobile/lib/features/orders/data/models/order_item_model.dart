/// Order Item Model
library;

import '../../domain/entities/order_item.dart';

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productUnit;
  final double quantity;
  final double unitPrice;
  final double total;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productUnit,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // Backend nests product info in a 'product' sub-object
    final product = json['product'] as Map<String, dynamic>?;

    return OrderItemModel(
      id: json['id'] as String,
      productId: product?['id'] as String? ?? json['product_id'] as String,
      productName: json['product_name_snapshot'] as String? ??
          product?['name'] as String? ??
          json['product_name'] as String? ??
          '',
      productUnit: product?['unit'] as String? ??
          json['product_unit'] as String? ??
          '',
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total_price'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
    );
  }

  OrderItem toEntity() {
    return OrderItem(
      id: id,
      productId: productId,
      productName: productName,
      productUnit: productUnit,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
    );
  }
}

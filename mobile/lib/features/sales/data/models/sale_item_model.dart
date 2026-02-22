import '../../domain/entities/sale_item.dart';

class SaleItemModel {
  final String id;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String productNameSnapshot;
  final String productUnitSnapshot;

  const SaleItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productNameSnapshot,
    required this.productUnitSnapshot,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      quantity: double.parse(json['quantity'].toString()),
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      productNameSnapshot: json['product_name_snapshot'] as String,
      productUnitSnapshot: json['product_unit_snapshot'] as String,
    );
  }

  SaleItem toEntity() => SaleItem(
        id: id,
        productId: productId,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        productNameSnapshot: productNameSnapshot,
        productUnitSnapshot: productUnitSnapshot,
      );
}

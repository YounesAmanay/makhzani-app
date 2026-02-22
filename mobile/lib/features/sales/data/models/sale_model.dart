import '../../domain/entities/sale.dart';
import 'sale_item_model.dart';

class SaleModel {
  final String id;
  final String saleNumber;
  final int totalItems;
  final double totalAmount;
  final String? notes;
  final bool isCancelled;
  final List<SaleItemModel> items;
  final DateTime createdAt;

  const SaleModel({
    required this.id,
    required this.saleNumber,
    required this.totalItems,
    required this.totalAmount,
    this.notes,
    required this.isCancelled,
    required this.items,
    required this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SaleModel(
      id: json['id'] as String,
      saleNumber: json['sale_number'] as String,
      totalItems: int.parse(json['total_items'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
      notes: json['notes'] as String?,
      isCancelled: json['is_cancelled'] as bool? ?? false,
      items: rawItems
          .map((i) => SaleItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Sale toEntity() => Sale(
        id: id,
        saleNumber: saleNumber,
        totalItems: totalItems,
        totalAmount: totalAmount,
        notes: notes,
        isCancelled: isCancelled,
        items: items.map((i) => i.toEntity()).toList(),
        createdAt: createdAt,
      );
}

import 'sale_item.dart';

class Sale {
  final String id;
  final String saleNumber;
  final int totalItems;
  final double totalAmount;
  final String? notes;
  final bool isCancelled;
  final List<SaleItem> items;
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.saleNumber,
    required this.totalItems,
    required this.totalAmount,
    this.notes,
    required this.isCancelled,
    required this.items,
    required this.createdAt,
  });
}

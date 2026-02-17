/// Order Item Entity
library;

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productUnit;
  final double quantity;
  final double unitPrice;
  final double total;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productUnit,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });
}

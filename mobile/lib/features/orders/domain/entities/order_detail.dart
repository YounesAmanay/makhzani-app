/// Order Detail Entity
library;

import 'order.dart';
import 'order_item.dart';

class OrderDetail extends Order {
  final List<OrderItem> items;

  OrderDetail({
    required super.id,
    required super.orderNumber,
    required super.supplier,
    required super.totalItems,
    required super.totalQuantity,
    required super.totalValue,
    super.notes,
    required super.status,
    super.pdfUrl,
    required super.createdAt,
    super.pdfGeneratedAt,
    super.sentAt,
    required this.items,
  });
}

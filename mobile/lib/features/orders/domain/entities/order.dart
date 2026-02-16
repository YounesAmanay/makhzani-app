/// Order Entity
///
/// Purchase order with supplier, items summary, and status.
library;

import 'order_status.dart';
import 'order_supplier.dart';

class Order {
  final String id;
  final String orderNumber;
  final OrderSupplier supplier;
  final int totalItems;
  final double totalQuantity;
  final double totalValue;
  final String? notes;
  final OrderStatus status;
  final String? pdfUrl;
  final DateTime createdAt;
  final DateTime? pdfGeneratedAt;
  final DateTime? sentAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.supplier,
    required this.totalItems,
    required this.totalQuantity,
    required this.totalValue,
    this.notes,
    required this.status,
    this.pdfUrl,
    required this.createdAt,
    this.pdfGeneratedAt,
    this.sentAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderNumber == other.orderNumber &&
          supplier == other.supplier &&
          totalItems == other.totalItems &&
          totalQuantity == other.totalQuantity &&
          totalValue == other.totalValue &&
          notes == other.notes &&
          status == other.status &&
          pdfUrl == other.pdfUrl &&
          createdAt == other.createdAt &&
          pdfGeneratedAt == other.pdfGeneratedAt &&
          sentAt == other.sentAt;

  @override
  int get hashCode => Object.hash(
        id,
        orderNumber,
        supplier,
        totalItems,
        totalQuantity,
        totalValue,
        notes,
        status,
        pdfUrl,
        createdAt,
        pdfGeneratedAt,
        sentAt,
      );
}

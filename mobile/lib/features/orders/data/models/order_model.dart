/// Order Model
library;

import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import 'order_supplier_model.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final OrderSupplierModel supplier;
  final int totalItems;
  final double totalQuantity;
  final double totalValue;
  final String? notes;
  final bool pdfGenerated;
  final bool sent;
  final String? sentVia;
  final String? pdfUrl;
  final DateTime createdAt;
  final DateTime? pdfGeneratedAt;
  final DateTime? sentAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.supplier,
    required this.totalItems,
    required this.totalQuantity,
    required this.totalValue,
    this.notes,
    required this.pdfGenerated,
    required this.sent,
    this.sentVia,
    this.pdfUrl,
    required this.createdAt,
    this.pdfGeneratedAt,
    this.sentAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>;

    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      supplier: OrderSupplierModel.fromJson(json['supplier'] as Map<String, dynamic>),
      totalItems: json['total_items'] as int,
      totalQuantity: (json['total_quantity'] as num).toDouble(),
      totalValue: (json['total_value'] as num).toDouble(),
      notes: json['notes'] as String?,
      pdfGenerated: status['pdf_generated'] as bool,
      sent: status['sent'] as bool,
      sentVia: status['sent_via'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      pdfGeneratedAt: json['pdf_generated_at'] != null
          ? DateTime.parse(json['pdf_generated_at'] as String)
          : null,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
    );
  }

  Order toEntity() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      supplier: supplier.toEntity(),
      totalItems: totalItems,
      totalQuantity: totalQuantity,
      totalValue: totalValue,
      notes: notes,
      status: OrderStatus(
        pdfGenerated: pdfGenerated,
        sent: sent,
        sentVia: sentVia,
      ),
      pdfUrl: pdfUrl,
      createdAt: createdAt,
      pdfGeneratedAt: pdfGeneratedAt,
      sentAt: sentAt,
    );
  }
}

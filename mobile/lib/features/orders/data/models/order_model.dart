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
  final bool received;
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
    this.received = false,
    this.pdfUrl,
    required this.createdAt,
    this.pdfGeneratedAt,
    this.sentAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Handle both list response (has 'status' object) and create response (no 'status')
    final status = json['status'] as Map<String, dynamic>?;

    // For create response, calculate from items if total_items not provided
    final totalItems = json['total_items'] as int? ??
        (json['items'] as List?)?.length ?? 0;

    // For create response, total_quantity might not be provided
    final totalQuantity = json['total_quantity'] != null
        ? (json['total_quantity'] as num).toDouble()
        : 0.0;

    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      supplier: OrderSupplierModel.fromJson(json['supplier'] as Map<String, dynamic>),
      totalItems: totalItems,
      totalQuantity: totalQuantity,
      totalValue: (json['total_value'] as num).toDouble(),
      notes: json['notes'] as String?,
      pdfGenerated: status?['pdf_generated'] as bool? ?? false,
      sent: status?['sent'] as bool? ?? false,
      sentVia: status?['sent_via'] as String?,
      received: status?['received'] as bool? ?? false,
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
        received: received,
      ),
      pdfUrl: pdfUrl,
      createdAt: createdAt,
      pdfGeneratedAt: pdfGeneratedAt,
      sentAt: sentAt,
    );
  }
}

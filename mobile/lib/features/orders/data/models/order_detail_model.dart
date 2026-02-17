/// Order Detail Model
library;

import '../../domain/entities/order_detail.dart';
import '../../domain/entities/order_status.dart';
import 'order_item_model.dart';
import 'order_supplier_model.dart';

class OrderDetailModel {
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
  final List<OrderItemModel> items;

  OrderDetailModel({
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
    required this.items,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>?;
    // Backend nests totals inside 'summary' object
    final summary = json['summary'] as Map<String, dynamic>?;
    // Backend nests timestamps inside 'timestamps' object
    final timestamps = json['timestamps'] as Map<String, dynamic>?;
    final itemsJson = json['items'] as List;

    return OrderDetailModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      supplier: OrderSupplierModel.fromJson(json['supplier'] as Map<String, dynamic>),
      totalItems: summary?['total_items'] as int? ?? itemsJson.length,
      totalQuantity: summary?['total_quantity'] != null
          ? (summary!['total_quantity'] as num).toDouble()
          : 0.0,
      totalValue: summary?['total_value'] != null
          ? (summary!['total_value'] as num).toDouble()
          : 0.0,
      notes: json['notes'] as String?,
      pdfGenerated: status?['pdf_generated'] as bool? ?? false,
      sent: status?['sent'] as bool? ?? false,
      sentVia: status?['sent_via'] as String?,
      pdfUrl: json['pdf_url'] as String?,
      createdAt: DateTime.parse(
        (timestamps?['created_at'] as String?) ??
            (json['created_at'] as String),
      ),
      pdfGeneratedAt: _parseDate(
        timestamps?['pdf_generated_at'] as String? ??
            json['pdf_generated_at'] as String?,
      ),
      sentAt: _parseDate(
        timestamps?['sent_at'] as String? ??
            json['sent_at'] as String?,
      ),
      items: itemsJson
          .map((json) => OrderItemModel.fromJson(json as Map<String, dynamic>))
          .toList(),
    );
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) return null;
    return DateTime.parse(value);
  }

  OrderDetail toEntity() {
    return OrderDetail(
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
      items: items.map((m) => m.toEntity()).toList(),
    );
  }
}

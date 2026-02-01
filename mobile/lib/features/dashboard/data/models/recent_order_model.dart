/// Recent Order Model (Data Layer)
///
/// JSON serialization for recent orders from API.
library;

import '../../domain/entities/recent_order.dart';

class RecentOrderModel {
  final String id;
  final String orderNumber;
  final String? supplierName;
  final DateTime createdAt;
  final bool pdfGenerated;
  final bool sent;

  const RecentOrderModel({
    required this.id,
    required this.orderNumber,
    this.supplierName,
    required this.createdAt,
    required this.pdfGenerated,
    required this.sent,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderModel(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      supplierName: json['supplier_name'],
      createdAt: DateTime.parse(json['created_at']),
      pdfGenerated: json['pdf_generated'] ?? false,
      sent: json['sent'] ?? false,
    );
  }

  RecentOrder toEntity() => RecentOrder(
    id: id,
    orderNumber: orderNumber,
    supplierName: supplierName,
    createdAt: createdAt,
    pdfGenerated: pdfGenerated,
    sent: sent,
  );
}

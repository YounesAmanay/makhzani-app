/// Supplier Order Entity
///
/// Lightweight entity for recent orders in supplier detail.
library;

class SupplierOrder {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final bool pdfGenerated;
  final bool sent;

  const SupplierOrder({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.pdfGenerated,
    required this.sent,
  });
}

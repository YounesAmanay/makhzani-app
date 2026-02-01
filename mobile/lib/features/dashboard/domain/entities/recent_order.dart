/// Recent Order Entity
///
/// Represents a recent purchase order summary.
library;

class RecentOrder {
  final String id;
  final String orderNumber;
  final String? supplierName;
  final DateTime createdAt;
  final bool pdfGenerated;
  final bool sent;

  const RecentOrder({
    required this.id,
    required this.orderNumber,
    this.supplierName,
    required this.createdAt,
    required this.pdfGenerated,
    required this.sent,
  });
}

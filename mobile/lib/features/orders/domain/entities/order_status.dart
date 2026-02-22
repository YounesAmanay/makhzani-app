/// Order Status Value Object
///
/// Represents the status of an order based on PDF generation and sending state.
library;

class OrderStatus {
  final bool pdfGenerated;
  final bool sent;
  final String? sentVia;
  final bool received;

  const OrderStatus({
    required this.pdfGenerated,
    required this.sent,
    this.sentVia,
    this.received = false,
  });

  // Computed properties
  bool get isDraft => !pdfGenerated;
  bool get isGenerated => pdfGenerated && !sent;
  bool get isSent => sent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderStatus &&
          runtimeType == other.runtimeType &&
          pdfGenerated == other.pdfGenerated &&
          sent == other.sent &&
          sentVia == other.sentVia &&
          received == other.received;

  @override
  int get hashCode => Object.hash(pdfGenerated, sent, sentVia, received);
}

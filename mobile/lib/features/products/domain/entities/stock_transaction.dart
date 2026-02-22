/// Stock Transaction Entity
///
/// Represents a single stock change event for audit history.
library;

class StockTransaction {
  final String id;
  final String productId;
  final String type;
  final int oldQuantity;
  final int newQuantity;
  final int changeAmount;
  final String? reason;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  const StockTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.oldQuantity,
    required this.newQuantity,
    required this.changeAmount,
    this.reason,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  bool get isIncrease => changeAmount > 0;
}

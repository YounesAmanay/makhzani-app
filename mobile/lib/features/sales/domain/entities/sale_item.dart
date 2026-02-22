class SaleItem {
  final String id;
  final String productId;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String productNameSnapshot;
  final String productUnitSnapshot;

  const SaleItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.productNameSnapshot,
    required this.productUnitSnapshot,
  });
}

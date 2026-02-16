/// Order Supplier Entity
///
/// Lightweight supplier info included in order list/detail.
library;

class OrderSupplier {
  final String id;
  final String name;
  final String? businessName;
  final String phoneNumber;

  const OrderSupplier({
    required this.id,
    required this.name,
    this.businessName,
    required this.phoneNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderSupplier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          businessName == other.businessName &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => Object.hash(id, name, businessName, phoneNumber);
}

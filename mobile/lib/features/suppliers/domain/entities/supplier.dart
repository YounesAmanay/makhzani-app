/// Supplier Entity
library;

class Supplier {
  final String id;
  final String name;
  final String? businessName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? city;
  final String? supplierType;
  final SupplierRelationship? relationship;

  const Supplier({
    required this.id,
    required this.name,
    this.businessName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.city,
    this.supplierType,
    this.relationship,
  });
}

class SupplierRelationship {
  final String? preferredContactMethod;
  final String? paymentTerms;
  final String? merchantNotes;
  final DateTime? lastOrderDate;
  final int totalOrders;
  final DateTime? linkedSince;

  const SupplierRelationship({
    this.preferredContactMethod,
    this.paymentTerms,
    this.merchantNotes,
    this.lastOrderDate,
    required this.totalOrders,
    this.linkedSince,
  });
}

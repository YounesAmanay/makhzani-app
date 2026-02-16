/// Supplier Model
library;

import '../../domain/entities/supplier.dart';

class SupplierModel {
  final String id;
  final String name;
  final String? businessName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? city;
  final String? supplierType;
  final SupplierRelationshipModel? relationship;

  const SupplierModel({
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

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'].toString(),
      name: json['name'],
      businessName: json['business_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      supplierType: json['supplier_type'],
      relationship: json['relationship'] != null
          ? SupplierRelationshipModel.fromJson(json['relationship'])
          : null,
    );
  }

  Supplier toEntity() => Supplier(
        id: id,
        name: name,
        businessName: businessName,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
        city: city,
        supplierType: supplierType,
        relationship: relationship?.toEntity(),
      );
}

class SupplierRelationshipModel {
  final String? preferredContactMethod;
  final String? paymentTerms;
  final String? merchantNotes;
  final DateTime? lastOrderDate;
  final int totalOrders;
  final DateTime? linkedSince;

  const SupplierRelationshipModel({
    this.preferredContactMethod,
    this.paymentTerms,
    this.merchantNotes,
    this.lastOrderDate,
    required this.totalOrders,
    this.linkedSince,
  });

  factory SupplierRelationshipModel.fromJson(Map<String, dynamic> json) {
    return SupplierRelationshipModel(
      preferredContactMethod: json['preferred_contact_method'],
      paymentTerms: json['payment_terms'],
      merchantNotes: json['merchant_notes'],
      lastOrderDate: json['last_order_date'] != null
          ? DateTime.tryParse(json['last_order_date'])
          : null,
      totalOrders: json['total_orders'] ?? 0,
      linkedSince: json['linked_since'] != null
          ? DateTime.tryParse(json['linked_since'])
          : null,
    );
  }

  SupplierRelationship toEntity() => SupplierRelationship(
        preferredContactMethod: preferredContactMethod,
        paymentTerms: paymentTerms,
        merchantNotes: merchantNotes,
        lastOrderDate: lastOrderDate,
        totalOrders: totalOrders,
        linkedSince: linkedSince,
      );
}

/// Supplier Model
library;

import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_order.dart';

class SupplierModel {
  final String id;
  final String name;
  final String? businessName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? city;
  final String? supplierType;
  final String? avatarUrl;
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
    this.avatarUrl,
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
      avatarUrl: json['avatar_url'],
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
        avatarUrl: avatarUrl,
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

class SupplierOrderModel {
  final String id;
  final String orderNumber;
  final DateTime createdAt;
  final bool pdfGenerated;
  final bool sent;

  const SupplierOrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.pdfGenerated,
    required this.sent,
  });

  factory SupplierOrderModel.fromJson(Map<String, dynamic> json) {
    return SupplierOrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'],
      createdAt: DateTime.parse(json['created_at']),
      pdfGenerated: json['pdf_generated'] ?? false,
      sent: json['sent'] ?? false,
    );
  }

  SupplierOrder toEntity() => SupplierOrder(
        id: id,
        orderNumber: orderNumber,
        createdAt: createdAt,
        pdfGenerated: pdfGenerated,
        sent: sent,
      );
}

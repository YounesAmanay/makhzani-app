/// Order Supplier Model
library;

import '../../domain/entities/order_supplier.dart';

class OrderSupplierModel {
  final String id;
  final String name;
  final String? businessName;
  final String phoneNumber;

  OrderSupplierModel({
    required this.id,
    required this.name,
    this.businessName,
    required this.phoneNumber,
  });

  factory OrderSupplierModel.fromJson(Map<String, dynamic> json) {
    return OrderSupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      businessName: json['business_name'] as String?,
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }

  OrderSupplier toEntity() {
    return OrderSupplier(
      id: id,
      name: name,
      businessName: businessName,
      phoneNumber: phoneNumber,
    );
  }
}

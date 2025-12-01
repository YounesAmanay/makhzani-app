class Supplier {
  final String id;
  final String name;
  final String? businessName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Supplier({
    required this.id,
    required this.name,
    this.businessName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      businessName: json['business_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_name': businessName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
class Merchant {
  final String id;
  final String? businessName;
  final String? ownerName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Merchant({
    required this.id,
    this.businessName,
    this.ownerName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      id: json['id'],
      businessName: json['business_name'],
      ownerName: json['owner_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
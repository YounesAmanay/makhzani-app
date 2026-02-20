/// Merchant Model (Data Layer)
///
/// This extends the domain entity with JSON serialization.
/// Used for API communication (parsing responses, sending requests).
///
/// Pattern:
/// - Extends or maps to the domain Entity
/// - Has fromJson (parse API response)
/// - Has toJson (send to API)
/// - Has toEntity (convert to domain entity)
library;

import '../../domain/entities/merchant.dart';

class MerchantModel {
  final String id;
  final String name;
  final String? email;
  final String shopName;
  final String phoneNumber;
  final String? address;
  final String? region;
  final String? status; // Nullable - not always returned
  final String subscriptionStatus;
  final DateTime? trialEndsAt;
  final bool? isNewUser;
  final String? avatarUrl;

  const MerchantModel({
    required this.id,
    required this.name,
    this.email,
    required this.shopName,
    required this.phoneNumber,
    this.address,
    this.region,
    this.status,
    required this.subscriptionStatus,
    this.trialEndsAt,
    this.isNewUser,
    this.avatarUrl,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      shopName: json['shop_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      region: json['region'],
      status: json['status'],
      subscriptionStatus: json['subscription_status'],
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'])
          : null,
      isNewUser: json['is_new_user'],
      avatarUrl: json['avatar_url'],
    );
  }

  Merchant toEntity() => Merchant(
    id: id,
    phoneNumber: phoneNumber,
    businessName: shopName,
    subscriptionStatus: subscriptionStatus,
    trialEndsAt: trialEndsAt,
    avatarUrl: avatarUrl,
    ownerName: name,
    shopName: shopName,
    address: address,
    region: region,
  );
}

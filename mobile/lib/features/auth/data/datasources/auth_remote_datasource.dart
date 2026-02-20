/// Auth Remote Data Source
///
/// Handles all API calls related to authentication.
/// This is the ONLY place where we talk to the auth API.
library;

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_tokens_model.dart';
import '../models/merchant_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<(AuthTokensModel, MerchantModel)> verifyOtp(String phoneNumber, String otp);
  Future<MerchantModel> getMerchantProfile();
  /// Returns the new avatar URL (relative path)
  Future<String> uploadMerchantAvatar(String filePath);
  /// Update editable profile fields; returns partial merchant map from backend
  Future<Map<String, dynamic>> updateProfile({
    String? ownerName,
    String? shopName,
    String? address,
    String? region,
  });
  /// Refresh is handled by ApiClient interceptor - no separate call needed
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'phone_number': phoneNumber},
    );
  }

  @override
  Future<(AuthTokensModel, MerchantModel)> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'phone_number': phoneNumber, 'otp': otp},
    );

    final data = response.data['data'];
    final tokens = AuthTokensModel.fromJson(data);
    final merchant = MerchantModel.fromJson(data['merchant']);

    return (tokens, merchant);
  }

  @override
  Future<MerchantModel> getMerchantProfile() async {
    final response = await _apiClient.get(ApiEndpoints.merchantProfile);
    return MerchantModel.fromJson(response.data['data']['merchant']);
  }

  @override
  Future<String> uploadMerchantAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.post(
      ApiEndpoints.merchantAvatar,
      data: formData,
    );
    return response.data['data']['avatar_url'] as String;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    String? ownerName,
    String? shopName,
    String? address,
    String? region,
  }) async {
    final body = <String, dynamic>{};
    if (ownerName != null) body['name'] = ownerName;
    if (shopName != null) body['shop_name'] = shopName;
    if (address != null) body['address'] = address;
    if (region != null) body['region'] = region;

    final response = await _apiClient.put(
      ApiEndpoints.merchantProfile,
      data: body,
    );
    // Backend returns partial merchant (no subscription_status/avatar_url)
    // Caller merges with existing state
    return Map<String, dynamic>.from(response.data['data']['merchant'] as Map);
  }
}

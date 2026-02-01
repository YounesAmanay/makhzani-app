/// Auth Remote Data Source
///
/// Handles all API calls related to authentication.
/// This is the ONLY place where we talk to the auth API.
library;

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/auth_tokens_model.dart';
import '../models/merchant_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<(AuthTokensModel, MerchantModel)> verifyOtp(String phoneNumber, String otp);
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

}

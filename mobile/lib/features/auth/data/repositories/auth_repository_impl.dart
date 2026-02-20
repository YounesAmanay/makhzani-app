/// Auth Repository Implementation
///
/// Implements the domain AuthRepository interface.
/// Coordinates between remote and local data sources.
library;

import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      await _remoteDataSource.sendOtp(phoneNumber);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<(AuthTokens, Merchant)> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    final (tokensModel, merchantModel) = await _remoteDataSource.verifyOtp(
      phoneNumber,
      otp,
    );

    // Save tokens locally
    await _localDataSource.saveTokens(tokensModel);

    // Convert to domain entities
    return (tokensModel.toEntity(), merchantModel.toEntity());
  }

  // Token refresh is handled automatically by ApiClient interceptor

  @override
  Future<void> logout() async {
    await _localDataSource.clearTokens();
  }

  @override
  Future<AuthTokens?> getStoredTokens() async {
    final tokens = await _localDataSource.getTokens();
    return tokens?.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localDataSource.hasTokens();
  }

  @override
  Future<Merchant> getMerchantProfile() async {
    final model = await _remoteDataSource.getMerchantProfile();
    return model.toEntity();
  }

  @override
  Future<String> uploadMerchantAvatar(String filePath) async {
    return await _remoteDataSource.uploadMerchantAvatar(filePath);
  }
}

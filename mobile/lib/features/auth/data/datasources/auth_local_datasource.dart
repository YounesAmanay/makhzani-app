/// Auth Local Data Source
///
/// Handles secure storage of authentication token.
/// Uses FlutterSecureStorage for encrypted token storage.
/// Note: Backend uses single-token JWT system (no separate refresh token).
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_tokens_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokensModel tokens);
  Future<AuthTokensModel?> getTokens();
  Future<void> clearTokens();
  Future<bool> hasTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';

  AuthLocalDataSourceImpl(this._storage);

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
  }

  @override
  Future<AuthTokensModel?> getTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);

    if (accessToken == null) {
      return null;
    }

    return AuthTokensModel(accessToken: accessToken);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
  }

  @override
  Future<bool> hasTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    return accessToken != null;
  }
}

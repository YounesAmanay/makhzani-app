/// Auth Tokens Model (Data Layer)
///
/// JSON serialization for authentication token from API.
/// Note: Backend uses single-token JWT system (no separate refresh token).
library;

import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel {
  final String accessToken;

  const AuthTokensModel({
    required this.accessToken,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) => AuthTokensModel(
    // Backend sends 'token', not 'accessToken'
    accessToken: json['token'] ?? json['accessToken'],
  );

  AuthTokens toEntity() => AuthTokens(
    accessToken: accessToken,
  );
}

/// Auth Tokens Entity
///
/// Holds the JWT token received after successful authentication.
/// Note: Backend uses single-token JWT system (no separate refresh token).
/// Token refresh is handled by ApiClient interceptor using the same token.
library;

class AuthTokens {
  final String accessToken;

  const AuthTokens({
    required this.accessToken,
  });
}

/// Auth Repository Interface (Contract)
///
/// Defines WHAT authentication operations are available.
/// The DATA layer will implement HOW they work.
///
/// This is the power of Clean Architecture:
/// - Domain defines the contract
/// - Data implements the contract
/// - Presentation uses the contract (not the implementation)
library;

import '../entities/auth_tokens.dart';
import '../entities/merchant.dart';

abstract class AuthRepository {
  /// Sends OTP to the given phone number
  Future<bool> sendOtp(String phoneNumber);

  /// Verifies OTP and returns tokens + merchant
  Future<(AuthTokens, Merchant)> verifyOtp(String phoneNumber, String otp);

  /// Logout - clears stored tokens
  Future<void> logout();

  /// Retrieves saved tokens (for app restart)
  Future<AuthTokens?> getStoredTokens();

  /// Checks if user has valid tokens
  Future<bool> isLoggedIn();

  Future<Merchant> getMerchantProfile();

  /// Uploads a new avatar image; returns the new avatar URL
  Future<String> uploadMerchantAvatar(String filePath);

  // Note: Token refresh is handled automatically by ApiClient interceptor
}

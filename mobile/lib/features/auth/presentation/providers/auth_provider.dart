/// Auth Provider
///
/// Riverpod provider for authentication state management.
/// Handles login flow, OTP verification, and auth state.
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth state - represents the current authentication status
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final Merchant? merchant;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.merchant,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Merchant? merchant,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      merchant: merchant ?? this.merchant,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Auth Notifier - manages authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  /// Check if user is already logged in (on app start)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);

    final isLoggedIn = await _authRepository.isLoggedIn();

    if (isLoggedIn) {
      try {
        final merchant = await _authRepository.getMerchantProfile();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          merchant: merchant,
        );
      } catch (_) {
        // Profile fetch failed (e.g. offline) — still mark authenticated
        state = state.copyWith(status: AuthStatus.authenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final success = await _authRepository.sendOtp(phoneNumber);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return success;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to send OTP',
      );
      return false;
    }
  }

  /// Verify OTP and login
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final (_, merchant) = await _authRepository.verifyOtp(phoneNumber, otp);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        merchant: merchant,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid OTP',
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Update editable profile fields and patch state
  Future<void> updateProfile({
    String? ownerName,
    String? shopName,
    String? address,
    String? region,
  }) async {
    try {
      final partial = await _authRepository.updateProfile(
        ownerName: ownerName,
        shopName: shopName,
        address: address,
        region: region,
      );
      // Backend returns partial merchant — merge with existing state
      final current = state.merchant!;
      final newShopName = partial['shop_name'] as String? ?? current.shopName;
      state = state.copyWith(
        merchant: Merchant(
          id: current.id,
          phoneNumber: current.phoneNumber,
          businessName: newShopName,
          subscriptionStatus: current.subscriptionStatus,
          trialEndsAt: current.trialEndsAt,
          avatarUrl: current.avatarUrl,
          ownerName: partial['name'] as String? ?? current.ownerName,
          shopName: newShopName,
          address: partial['address'] as String? ?? current.address,
          region: partial['region'] as String? ?? current.region,
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          final fieldErrors = <String, String>{};
          for (final err in errors) {
            if (err is Map) {
              final field = err['path'] as String?;
              final msg = err['msg'] as String?;
              if (field != null && msg != null) fieldErrors[field] = msg;
            }
          }
          throw ProfileUpdateException(
            message: data['message'] as String? ?? 'Update failed',
            fieldErrors: fieldErrors,
          );
        }
      }
      throw ProfileUpdateException(
        message: (data is Map ? data['message'] as String? : null) ?? 'Failed to update profile',
      );
    }
  }

  /// Upload avatar and patch avatarUrl on the current merchant in state
  Future<void> uploadAvatar(String filePath) async {
    try {
      final avatarUrl = await _authRepository.uploadMerchantAvatar(filePath);
      final current = state.merchant ?? await _authRepository.getMerchantProfile();
      state = state.copyWith(
        merchant: Merchant(
          id: current.id,
          phoneNumber: current.phoneNumber,
          businessName: current.businessName,
          subscriptionStatus: current.subscriptionStatus,
          trialEndsAt: current.trialEndsAt,
          avatarUrl: avatarUrl,
          ownerName: current.ownerName,
          shopName: current.shopName,
          address: current.address,
          region: current.region,
        ),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ?? 'Failed to upload avatar';
      throw Exception(message);
    }
  }
}

/// Structured exception for profile update errors — carries field-level errors
class ProfileUpdateException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;

  const ProfileUpdateException({
    required this.message,
    this.fieldErrors = const {},
  });
}

/// Providers

// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.read(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.read(secureStorageProvider));
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(authLocalDataSourceProvider),
  );
});

// Auth state notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

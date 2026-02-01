/// Auth Provider
///
/// Riverpod provider for authentication state management.
/// Handles login flow, OTP verification, and auth state.
library;

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
      state = state.copyWith(status: AuthStatus.authenticated);
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

/// OTP Verification Screen
///
/// Second step of authentication - user enters the OTP code.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _onVerifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).verifyOtp(
      widget.phoneNumber,
      otp,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Navigate to dashboard - clear all previous screens
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard',
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid code. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onResendOtp() async {
    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).sendOtp(
      widget.phoneNumber,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Code resent successfully' : 'Failed to resend code',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Icon
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.marginMedium),

              // Title
              Text(
                'Enter verification code',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.marginSmall),

              // Subtitle
              Text(
                'We sent a 4-digit code to\n${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.marginXLarge),

              // OTP Input
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  letterSpacing: 16,
                  fontWeight: FontWeight.bold,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  hintText: '• • • •',
                  counterText: '',
                ),
                onChanged: (value) {
                  // Auto-submit when 4 digits entered
                  if (value.length == 4) {
                    _onVerifyOtp();
                  }
                },
              ),

              const SizedBox(height: AppDimensions.marginLarge),

              // Verify button
              ElevatedButton(
                onPressed: _isLoading ? null : _onVerifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),

              const SizedBox(height: AppDimensions.marginMedium),

              // Resend button
              TextButton(
                onPressed: _isLoading ? null : _onResendOtp,
                child: const Text('Resend Code'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

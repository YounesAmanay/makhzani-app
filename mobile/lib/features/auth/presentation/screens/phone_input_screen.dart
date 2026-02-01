/// Phone Input Screen
///
/// First step of authentication - user enters their phone number.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/auth_provider.dart';
import 'otp_verification_screen.dart';

class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber => '+212${_phoneController.text}';

  Future<void> _onSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).sendOtp(
      _fullPhoneNumber,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: _fullPhoneNumber,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Logo/Title section
                const Icon(
                  Icons.store_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                Text(
                  'Makhzani',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                Text(
                  'Enter your phone number to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Phone input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '6XXXXXXXX',
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🇲🇦',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+212',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.border,
                          ),
                        ],
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 9) {
                      return 'Phone number must be 9 digits';
                    }
                    // Morocco mobile numbers start with 5, 6, or 7
                    if (!RegExp(r'^[567]').hasMatch(value)) {
                      return 'Phone number must start with 5, 6, or 7';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.marginLarge),

                // Send OTP button
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Send Code'),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

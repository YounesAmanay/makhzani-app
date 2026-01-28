import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String phone) {
    // Remove any whitespace
    phone = phone.trim().replaceAll(' ', '');

    // Check if empty
    if (phone.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove leading zero if present (Moroccan numbers often start with 0)
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    // Check if it contains only digits
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Phone number should contain only digits';
    }

    // Moroccan phone numbers are 9 digits (without country code)
    if (phone.length != 9) {
      return 'Phone number must be 9 digits';
    }

    // Check if it starts with valid Moroccan mobile prefixes (6 or 7)
    if (!phone.startsWith('6') && !phone.startsWith('7')) {
      return 'Phone number must start with 6 or 7';
    }

    return null; // Valid
  }

  Future<void> _sendOtp() async {
    // Clean phone number
    String cleanPhone = _phoneController.text.trim().replaceAll(' ', '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }

    // Validate phone number
    String? validationError = _validatePhoneNumber(cleanPhone);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine prefix with cleaned user input
      String fullPhoneNumber = '+212$cleanPhone';
      await _authService.sendOtp(fullPhoneNumber);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(phoneNumber: fullPhoneNumber),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please check your connection and try again.'),
            backgroundColor: Color(AppConstants.errorColor),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryGreen),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 40,
                    color: Color(AppConstants.white),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textDark),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(AppConstants.textGray),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Input Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.white),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Phone Input
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(AppConstants.textDark),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '612345678',
                          prefixText: '+212 ',
                          prefixStyle: const TextStyle(
                            color: Color(AppConstants.textDark),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(AppConstants.paleGreen),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              color: Color(AppConstants.primaryGreen),
                              size: 20,
                            ),
                          ),
                          helperText: 'Enter your 9-digit mobile number',
                          helperStyle: const TextStyle(
                            color: Color(AppConstants.textLight),
                            fontSize: 12,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(AppConstants.textLight).withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(AppConstants.textLight).withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(AppConstants.primaryGreen),
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(AppConstants.errorColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Send OTP Button
                      CustomButton(
                        text: _isLoading ? 'Sending...' : 'Continue',
                        onPressed: _isLoading ? null : _sendOtp,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Text
                Text(
                  'We will send you a verification code via SMS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(AppConstants.textLight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
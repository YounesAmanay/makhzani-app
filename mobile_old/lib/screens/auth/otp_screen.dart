import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../dashboard/dashboard_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;

  const OTPScreen({super.key, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (index) => FocusNode());
  final _authService = AuthService();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendTimer = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(AppConstants.white),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(AppConstants.textDark),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.paleGreen),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    size: 40,
                    color: Color(AppConstants.primaryGreen),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  'Verify Your Phone',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Enter the 4-digit code sent to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color(AppConstants.textGray),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.phoneNumber,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(AppConstants.textDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 48),

                // OTP Input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      child: _buildOTPBox(index),
                    );
                  }),
                ),

                const SizedBox(height: 48),

                // Verify button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: _isLoading ? 'Verifying...' : 'Verify Code',
                    onPressed: _isLoading ? null : _verifyOTP,
                    isLoading: _isLoading,
                  ),
                ),

                const SizedBox(height: 32),

                // Resend option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(AppConstants.textGray),
                      ),
                    ),
                    TextButton(
                      onPressed: _canResend ? _resendOTP : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _canResend ? 'Resend' : 'Resend (${_resendTimer}s)',
                        style: TextStyle(
                          fontSize: 14,
                          color: _canResend
                              ? const Color(AppConstants.primaryGreen)
                              : const Color(AppConstants.textLight),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: const Color(AppConstants.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNodes[index].hasFocus
              ? const Color(AppConstants.primaryGreen)
              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
          width: _focusNodes[index].hasFocus ? 2.5 : 1.5,
        ),
        boxShadow: _focusNodes[index].hasFocus
            ? [
                BoxShadow(
                  color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.textDark),
            height: 1.0,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onOTPChanged(value, index),
        ),
      ),
    );
  }

  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOTP() async {
    String otp = _controllers.map((c) => c.text).join();

    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 4-digit code'),
          backgroundColor: Color(AppConstants.warningColor),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.verifyOtpAndLogin(widget.phoneNumber, otp);

      if (mounted) {
        if (response['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Color(AppConstants.successColor),
              duration: Duration(seconds: 1),
            ),
          );

          // Navigate to dashboard and clear navigation stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        } else {
          // Handle unsuccessful response
          String errorMessage = response['message'] ?? 'Verification failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: const Color(AppConstants.errorColor),
            ),
          );
          // Clear OTP fields
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Invalid OTP code. Please try again.';

        // Check for specific error types
        if (e.toString().contains('Failed to verify OTP')) {
          errorMessage = 'Invalid OTP code. Please check and try again.';
        } else if (e.toString().contains('timeout') || e.toString().contains('connection')) {
          errorMessage = 'Connection timeout. Please check your internet and try again.';
        } else if (e.toString().contains('expired')) {
          errorMessage = 'OTP has expired. Please request a new code.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Resend',
              textColor: Colors.white,
              onPressed: _canResend ? _resendOTP : () {},
            ),
          ),
        );

        // Clear OTP fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resendOTP() async {
    setState(() {
      _canResend = false;
      _resendTimer = 60;
    });
    _startResendTimer();

    try {
      await _authService.sendOtp(widget.phoneNumber);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New OTP code sent successfully'),
            backgroundColor: Color(AppConstants.successColor),
            duration: Duration(seconds: 2),
          ),
        );
        // Clear existing OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to resend OTP. Please try again.';

        if (e.toString().contains('timeout') || e.toString().contains('connection')) {
          errorMessage = 'Connection error. Please check your internet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 3),
          ),
        );

        // Reset timer so user can try again
        setState(() {
          _canResend = true;
          _resendTimer = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    return await ApiService.sendOTP(phoneNumber);
  }

  Future<Map<String, dynamic>> verifyOtpAndLogin(String phoneNumber, String otp) async {
    final response = await ApiService.verifyOTP(phoneNumber, otp);

    if (response['success'] == true) {
      final token = response['data']['token'];
      final merchantId = response['data']['merchant']['id'];

      await _saveAuthData(token, merchantId, phoneNumber);
    }

    return response;
  }

  Future<void> _saveAuthData(String token, String merchantId, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString('merchant_id', merchantId);
    await prefs.setString('phone_number', phoneNumber);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<String?> getMerchantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('merchant_id');
  }

  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone_number');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove('merchant_id');
    await prefs.remove('phone_number');
  }
}
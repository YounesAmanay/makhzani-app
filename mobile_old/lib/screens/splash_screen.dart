import 'package:flutter/material.dart';
import 'dart:async';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is already logged in
    final isLoggedIn = await _authService.isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        // User is logged in, go to dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // User not logged in, go to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.white),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container - Clean circular design
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.primaryGreen),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    size: 60,
                    color: Color(AppConstants.white),
                  ),
                ),
                const SizedBox(height: 40),

                // App Name
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textDark),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),

                // Tagline
                Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(AppConstants.textGray),
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(AppConstants.primaryGreen),
                    ),
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

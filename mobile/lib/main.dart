import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MakhzaniApp());
}

class MakhzaniApp extends StatelessWidget {
  const MakhzaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppConstants.primaryGreen),
            primary: const Color(AppConstants.primaryGreen),
            secondary: const Color(AppConstants.darkGreen),
            surface: const Color(AppConstants.white),
            error: const Color(AppConstants.errorColor),
          ),
          scaffoldBackgroundColor: const Color(AppConstants.background),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(AppConstants.white),
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(AppConstants.textDark)),
            titleTextStyle: TextStyle(
              color: Color(AppConstants.textDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(AppConstants.white),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black.withValues(alpha: 0.05),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(AppConstants.white),
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
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textDark),
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textDark),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(AppConstants.textDark),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(AppConstants.textGray),
            ),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // For now, always show login screen
        // Later we'll check if user is already authenticated
        return const LoginScreen();
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/phone_input_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MakhzaniApp(),
    ),
  );
}

class MakhzaniApp extends StatelessWidget {
  const MakhzaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Makhzani',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('fr'),
        Locale('en'),
      ],
      locale: const Locale('en'), // Start with English for now

      // Routes
      routes: {
        '/': (context) => const PhoneInputScreen(),
        '/dashboard': (context) => const DashboardPlaceholder(),
      },
    );
  }
}

/// Temporary dashboard placeholder
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome! Dashboard coming soon...'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/generated/app_localizations.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MakhzaniApp());
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
        Locale('ar'), // Arabic
        Locale('fr'), // French
        Locale('en'), // English
      ],
      locale: const Locale('ar'), // Default to Arabic

      // Home
      home: const TestScreen(),
    );
  }
}

// Temporary test screen
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: Text(l10n.login),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ],
        ),
      ),
    );
  }
}

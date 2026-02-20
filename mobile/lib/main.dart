import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/services/preferences_provider.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/screens/phone_input_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/orders/presentation/screens/order_detail_screen.dart';
import 'features/orders/presentation/screens/order_form_screen.dart';
import 'features/products/presentation/screens/barcode_scanner_screen.dart';
import 'features/products/presentation/screens/product_detail_screen.dart';
import 'features/products/presentation/screens/product_form_screen.dart';
import 'features/settings/presentation/screens/settings_placeholder_screen.dart';
import 'features/shell/presentation/screens/main_shell_screen.dart';
import 'features/suppliers/presentation/screens/supplier_detail_screen.dart';
import 'features/suppliers/presentation/screens/supplier_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferencesService),
      ],
      child: const MakhzaniApp(),
    ),
  );
}

class MakhzaniApp extends ConsumerWidget {
  const MakhzaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Makhzani',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

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
      locale: locale,

      // Routes
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const PhoneInputScreen(),
        '/main': (context) => const MainShellScreen(),
        '/products/create': (context) => const ProductFormScreen(),
        '/products/scan': (context) => const BarcodeScannerScreen(),
        '/suppliers/create': (context) => const SupplierFormScreen(),
        '/orders/create': (context) => const OrderFormScreen(),
        '/settings': (context) => const SettingsPlaceholderScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/products/detail') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          );
        }
        if (settings.name == '/products/edit') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ProductFormScreen(productId: productId),
          );
        }
        if (settings.name == '/suppliers/detail') {
          final supplierId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => SupplierDetailScreen(supplierId: supplierId),
          );
        }
        if (settings.name == '/suppliers/edit') {
          final supplierId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => SupplierFormScreen(supplierId: supplierId),
          );
        }
        if (settings.name == '/orders/detail') {
          final orderId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}

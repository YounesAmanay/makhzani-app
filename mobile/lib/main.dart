import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'core/localization/generated/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/preferences_provider.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/screens/phone_input_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/notifications/data/datasources/notifications_local_datasource.dart';
import 'features/notifications/data/models/app_notification_hive_model.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/orders/presentation/screens/order_form_screen.dart';
import 'features/orders/presentation/screens/order_review_screen.dart';
import 'features/products/presentation/screens/barcode_scanner_screen.dart';
import 'features/products/presentation/screens/csv_screen.dart';
import 'features/products/presentation/screens/product_detail_screen.dart';
import 'features/products/presentation/screens/product_form_screen.dart';
import 'features/settings/presentation/screens/settings_placeholder_screen.dart';
import 'features/shell/presentation/screens/main_shell_screen.dart';
import 'features/suppliers/presentation/screens/supplier_detail_screen.dart';
import 'features/suppliers/presentation/screens/supplier_form_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(AppNotificationAdapter());
  await NotificationsLocalDatasource.openBox();

  // Initialize Firebase and request notification permission
  await NotificationService.initialize();

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

final navigatorKey = GlobalKey<NavigatorState>();

class MakhzaniApp extends ConsumerStatefulWidget {
  const MakhzaniApp({super.key});

  @override
  ConsumerState<MakhzaniApp> createState() => _MakhzaniAppState();
}

class _MakhzaniAppState extends ConsumerState<MakhzaniApp> {
  @override
  void initState() {
    super.initState();
    NotificationService.setupTapHandlers(
      onTap: _handleNotificationTap,
      onNewNotification: (notification) {
        // Update the notifications inbox provider in real-time
        ref.read(notificationsProvider.notifier).onNewNotification(notification);
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;
    final productId = data['product_id'] as String?;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    if (screen == 'product_detail' && productId != null) {
      navigator.pushNamed('/products/detail', arguments: productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
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
        '/products/csv': (context) => const CsvScreen(),
        '/suppliers/create': (context) => const SupplierFormScreen(),
        '/orders/create': (context) => const OrderFormScreen(),
        '/notifications': (context) => const NotificationsScreen(),
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
            builder: (context) => OrderReviewScreen(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}

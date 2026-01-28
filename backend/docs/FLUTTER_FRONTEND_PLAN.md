# Makhzani App - Flutter Frontend Setup Plan

**Version:** 2.0.0 (Complete Rebuild)
**Target Platforms:** Android, iOS
**Min SDK:** Flutter 3.24+ / Dart 3.5+

---

## Table of Contents
1. [Project Requirements](#project-requirements)
2. [Architecture & Patterns](#architecture--patterns)
3. [Folder Structure](#folder-structure)
4. [Dependencies & Packages](#dependencies--packages)
5. [State Management](#state-management)
6. [Localization (i18n)](#localization-i18n)
7. [Theming & Styling](#theming--styling)
8. [Navigation](#navigation)
9. [API Integration](#api-integration)
10. [Local Storage](#local-storage)
11. [Error Handling](#error-handling)
12. [Code Generation](#code-generation)
13. [Testing Strategy](#testing-strategy)
14. [Performance Optimization](#performance-optimization)
15. [Security Best Practices](#security-best-practices)
16. [Implementation Roadmap](#implementation-roadmap)

---

## Project Requirements

### Functional Requirements
1. **Authentication**
   - Phone number + OTP login (Morocco format: +212XXXXXXXXX)
   - JWT token management with auto-refresh
   - Secure token storage
   - Remember me functionality
   - Logout with confirmation

2. **Dashboard**
   - Quick stats overview (products, low stock, suppliers, orders)
   - Low stock alerts with visual indicators
   - Recent orders list
   - Quick action buttons (New Order, Add Product, etc.)

3. **Product Management**
   - List products with search & filters
   - Add/Edit/Delete products
   - Stock adjustment (add/subtract)
   - Barcode scanning support
   - Pagination for large lists
   - Low stock indicators

4. **Supplier Management**
   - List suppliers with relationship details
   - Add/Link new suppliers
   - Edit supplier relationship notes
   - View supplier order history
   - Remove supplier (with validation)

5. **Order Management**
   - Create purchase orders
   - List orders with filters (supplier, status)
   - View order details
   - Generate PDF
   - Download PDF to device
   - Mark as sent (WhatsApp, email, phone, in-person)
   - Share PDF via multiple channels

6. **Profile & Settings**
   - View/Edit merchant profile
   - Region selection
   - App settings (language, theme)
   - About & version info

### Non-Functional Requirements
1. **Performance**
   - Fast app startup (< 3 seconds)
   - Smooth scrolling (60 FPS)
   - Optimistic UI updates
   - Image lazy loading
   - Efficient list rendering

2. **Offline Support**
   - Cache essential data (products, suppliers)
   - Queue actions when offline
   - Sync when connection restored
   - Offline indicators

3. **UX/UI**
   - Clean, modern design
   - Intuitive navigation
   - Proper loading states
   - Error feedback
   - Success confirmations
   - Empty states with actions
   - Skeleton loaders

4. **Accessibility**
   - RTL support for Arabic
   - Screen reader support
   - Proper contrast ratios
   - Touch target sizes (min 44x44)
   - Semantic labels

5. **Localization**
   - Arabic (العربية) - Primary
   - French (Français) - Secondary
   - English (English) - Optional
   - RTL layout support

---

## Architecture & Patterns

### Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Widgets, Screens, ViewModels)     │
├─────────────────────────────────────────┤
│         Domain Layer                    │
│  (Entities, Use Cases, Repositories)    │
├─────────────────────────────────────────┤
│         Data Layer                      │
│  (API, Database, Models, DTOs)          │
└─────────────────────────────────────────┘
```

### Design Patterns
1. **MVVM (Model-View-ViewModel)** - For UI logic separation
2. **Repository Pattern** - For data access abstraction
3. **Dependency Injection** - Using `get_it` for service location
4. **Factory Pattern** - For object creation
5. **Singleton Pattern** - For services (API, Storage)
6. **Observer Pattern** - Via Riverpod providers

---

## Folder Structure

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # App widget with theme & routing
│
├── core/                               # Core utilities & configurations
│   ├── config/
│   │   ├── app_config.dart            # Environment configs
│   │   └── routes.dart                # Route definitions
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide constants
│   │   ├── api_endpoints.dart         # API endpoint constants
│   │   └── storage_keys.dart          # Local storage keys
│   ├── theme/
│   │   ├── app_theme.dart             # Theme configuration
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_text_styles.dart       # Text styles
│   │   └── app_dimensions.dart        # Spacing, sizes
│   ├── localization/
│   │   ├── app_localizations.dart     # Localization setup
│   │   ├── l10n/                      # Translation files
│   │   │   ├── app_ar.arb            # Arabic
│   │   │   ├── app_fr.arb            # French
│   │   │   └── app_en.arb            # English
│   ├── error/
│   │   ├── exceptions.dart            # Custom exceptions
│   │   ├── failures.dart              # Failure classes
│   │   └── error_handler.dart         # Global error handler
│   ├── network/
│   │   ├── api_client.dart            # HTTP client setup
│   │   ├── api_interceptor.dart       # Auth & logging interceptors
│   │   └── network_info.dart          # Connectivity checker
│   └── utils/
│       ├── validators.dart            # Form validators
│       ├── formatters.dart            # Text formatters
│       ├── date_utils.dart            # Date helpers
│       └── extensions.dart            # Dart extensions
│
├── features/                           # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── auth_request.dart
│   │   │   │   ├── auth_response.dart
│   │   │   │   └── merchant_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── merchant.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── send_otp.dart
│   │   │       ├── verify_otp.dart
│   │   │       ├── refresh_token.dart
│   │   │       └── logout.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── screens/
│   │       │   ├── splash_screen.dart
│   │       │   ├── login_screen.dart
│   │       │   └── otp_verification_screen.dart
│   │       └── widgets/
│   │           ├── phone_input_field.dart
│   │           ├── otp_input_field.dart
│   │           └── auth_button.dart
│   │
│   ├── dashboard/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── dashboard_stats_model.dart
│   │   │   ├── datasources/
│   │   │   │   └── dashboard_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── dashboard_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── dashboard_stats.dart
│   │   │   ├── repositories/
│   │   │   │   └── dashboard_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_dashboard_stats.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── dashboard_provider.dart
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── stat_card.dart
│   │           ├── low_stock_list.dart
│   │           ├── recent_orders_list.dart
│   │           └── quick_actions.dart
│   │
│   ├── products/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── product_model.dart
│   │   │   │   └── product_list_response.dart
│   │   │   ├── datasources/
│   │   │   │   ├── product_remote_datasource.dart
│   │   │   │   └── product_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── product_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_products.dart
│   │   │       ├── create_product.dart
│   │   │       ├── update_product.dart
│   │   │       ├── delete_product.dart
│   │   │       └── adjust_stock.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── products_provider.dart
│   │       │   └── product_form_provider.dart
│   │       ├── screens/
│   │       │   ├── products_list_screen.dart
│   │       │   ├── product_detail_screen.dart
│   │       │   └── product_form_screen.dart
│   │       └── widgets/
│   │           ├── product_card.dart
│   │           ├── product_search_bar.dart
│   │           ├── stock_indicator.dart
│   │           └── barcode_scanner_widget.dart
│   │
│   ├── suppliers/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── supplier_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── supplier_remote_datasource.dart
│   │   │   │   └── supplier_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── supplier_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── supplier.dart
│   │   │   ├── repositories/
│   │   │   │   └── supplier_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_suppliers.dart
│   │   │       ├── add_supplier.dart
│   │   │       ├── update_supplier.dart
│   │   │       └── remove_supplier.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── suppliers_provider.dart
│   │       ├── screens/
│   │       │   ├── suppliers_list_screen.dart
│   │       │   ├── supplier_detail_screen.dart
│   │       │   └── supplier_form_screen.dart
│   │       └── widgets/
│   │           ├── supplier_card.dart
│   │           └── contact_method_selector.dart
│   │
│   ├── orders/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── order_model.dart
│   │   │   │   └── order_item_model.dart
│   │   │   ├── datasources/
│   │   │   │   ├── order_remote_datasource.dart
│   │   │   │   └── order_local_datasource.dart
│   │   │   └── repositories/
│   │   │       └── order_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── order.dart
│   │   │   │   └── order_item.dart
│   │   │   ├── repositories/
│   │   │   │   └── order_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_orders.dart
│   │   │       ├── create_order.dart
│   │   │       ├── get_order_detail.dart
│   │   │       ├── generate_pdf.dart
│   │   │       ├── download_pdf.dart
│   │   │       └── mark_as_sent.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── orders_provider.dart
│   │       │   └── order_form_provider.dart
│   │       ├── screens/
│   │       │   ├── orders_list_screen.dart
│   │       │   ├── order_detail_screen.dart
│   │       │   └── create_order_screen.dart
│   │       └── widgets/
│   │           ├── order_card.dart
│   │           ├── order_item_row.dart
│   │           ├── product_selector.dart
│   │           └── pdf_actions.dart
│   │
│   └── profile/
│       ├── data/
│       │   ├── models/
│       │   │   └── profile_model.dart
│       │   ├── datasources/
│       │   │   └── profile_remote_datasource.dart
│       │   └── repositories/
│       │       └── profile_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── profile.dart
│       │   ├── repositories/
│       │   │   └── profile_repository.dart
│       │   └── usecases/
│       │       ├── get_profile.dart
│       │       └── update_profile.dart
│       └── presentation/
│           ├── providers/
│           │   └── profile_provider.dart
│           ├── screens/
│           │   ├── profile_screen.dart
│           │   ├── edit_profile_screen.dart
│           │   └── settings_screen.dart
│           └── widgets/
│               ├── profile_header.dart
│               └── settings_tile.dart
│
├── shared/                             # Shared components
│   ├── widgets/
│   │   ├── custom_app_bar.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── loading_indicator.dart
│   │   ├── error_widget.dart
│   │   ├── empty_state.dart
│   │   ├── confirmation_dialog.dart
│   │   ├── bottom_sheet_wrapper.dart
│   │   └── skeleton_loader.dart
│   ├── models/
│   │   ├── api_response.dart
│   │   └── pagination.dart
│   └── providers/
│       ├── theme_provider.dart
│       └── locale_provider.dart
│
└── di/                                 # Dependency Injection
    └── injection_container.dart        # GetIt setup
```

---

## Dependencies & Packages

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1              # Modern state management
  riverpod_annotation: ^2.3.5           # Code generation for Riverpod

  # Navigation
  go_router: ^14.2.0                    # Declarative routing

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0                         # Internationalization

  # Network
  dio: ^5.4.3+1                         # HTTP client
  pretty_dio_logger: ^1.4.0             # Network logging
  connectivity_plus: ^6.0.5             # Network connectivity

  # Local Storage
  shared_preferences: ^2.2.3            # Key-value storage
  flutter_secure_storage: ^9.2.2        # Secure storage for tokens
  sqflite: ^2.3.3+1                     # SQLite database
  hive: ^2.2.3                          # Fast key-value database
  hive_flutter: ^1.1.0

  # JSON Serialization
  json_annotation: ^4.9.0
  freezed_annotation: ^2.4.4            # Immutable models

  # Dependency Injection
  get_it: ^7.7.0                        # Service locator
  injectable: ^2.4.4                    # Code generation for DI

  # UI Components & Utilities
  cached_network_image: ^3.3.1          # Image caching
  flutter_svg: ^2.0.10+1                # SVG support
  shimmer: ^3.0.0                       # Skeleton loaders
  lottie: ^3.1.2                        # Animations
  flutter_slidable: ^3.1.1              # Swipe actions
  pull_to_refresh: ^2.0.0               # Pull to refresh

  # Forms & Validation
  reactive_forms: ^17.0.1               # Reactive form handling
  mask_text_input_formatter: ^2.9.0     # Input masking

  # Device Features
  permission_handler: ^11.3.1           # Permissions
  image_picker: ^1.1.2                  # Camera/Gallery
  mobile_scanner: ^5.1.1                # Barcode scanning
  url_launcher: ^6.3.0                  # Open URLs/WhatsApp
  share_plus: ^9.0.0                    # Share functionality
  path_provider: ^2.1.4                 # File paths

  # PDF
  pdf: ^3.11.1                          # PDF generation (if needed)
  open_file: ^3.3.2                     # Open downloaded files

  # Utilities
  equatable: ^2.0.5                     # Value equality
  dartz: ^0.10.1                        # Functional programming (Either)
  logger: ^2.4.0                        # Logging
  collection: ^1.18.0                   # Collection utilities

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting & Analysis
  flutter_lints: ^4.0.0
  very_good_analysis: ^6.0.0            # Stricter lints

  # Code Generation
  build_runner: ^2.4.11
  json_serializable: ^6.8.0
  freezed: ^2.5.7
  riverpod_generator: ^2.4.3
  injectable_generator: ^2.6.2
  go_router_builder: ^2.7.1

  # Testing
  mockito: ^5.4.4                       # Mocking
  mocktail: ^1.0.4                      # Alternative mocking
  integration_test:
    sdk: flutter

  # Icons
  flutter_launcher_icons: ^0.13.1       # App icons
```

---

## State Management

### Riverpod Setup

**Why Riverpod?**
- Type-safe
- Compile-time safety
- No BuildContext needed
- Better testing
- Code generation support
- Modern and actively maintained

**Provider Types:**

1. **StateProvider** - Simple state
```dart
final counterProvider = StateProvider<int>((ref) => 0);
```

2. **StateNotifierProvider** - Complex state with logic
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() => AuthState.initial();

  Future<void> login(String phone) async {
    state = AuthState.loading();
    // ... login logic
  }
}
```

3. **FutureProvider** - Async data
```dart
@riverpod
Future<List<Product>> products(ProductsRef ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
}
```

4. **StreamProvider** - Streaming data
```dart
@riverpod
Stream<List<Order>> ordersStream(OrdersStreamRef ref) {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.watchOrders();
}
```

**State Classes with Freezed:**
```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(Merchant merchant) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}
```

---

## Localization (i18n)

### Setup Strategy

1. **Flutter's Official i18n** (flutter_localizations + intl)

2. **ARB Files** (Application Resource Bundle)

**File: lib/core/localization/l10n/app_ar.arb**
```json
{
  "@@locale": "ar",
  "appName": "مخزني",
  "welcome": "مرحباً بك",
  "login": "تسجيل الدخول",
  "phoneNumber": "رقم الهاتف",
  "enterPhoneNumber": "أدخل رقم هاتفك",
  "sendOTP": "إرسال رمز التحقق",
  "verifyOTP": "تحقق من الرمز",
  "dashboard": "لوحة التحكم",
  "products": "المنتجات",
  "suppliers": "الموردون",
  "orders": "الطلبات",
  "profile": "الملف الشخصي",
  "addProduct": "إضافة منتج",
  "productName": "اسم المنتج",
  "stock": "المخزون",
  "lowStock": "مخزون منخفض",
  "reorderThreshold": "حد إعادة الطلب",
  "save": "حفظ",
  "cancel": "إلغاء",
  "delete": "حذف",
  "edit": "تعديل",
  "search": "بحث",
  "filter": "تصفية",
  "logout": "تسجيل الخروج",
  "confirmLogout": "هل أنت متأكد من تسجيل الخروج؟",
  "yes": "نعم",
  "no": "لا",
  "errorOccurred": "حدث خطأ",
  "tryAgain": "حاول مرة أخرى",
  "noConnection": "لا يوجد اتصال بالإنترنت",
  "loading": "جاري التحميل...",
  "emptyProducts": "لا توجد منتجات",
  "emptySuppliers": "لا يوجد موردون",
  "emptyOrders": "لا توجد طلبات"
}
```

**File: lib/core/localization/l10n/app_fr.arb**
```json
{
  "@@locale": "fr",
  "appName": "Makhzani",
  "welcome": "Bienvenue",
  "login": "Se connecter",
  "phoneNumber": "Numéro de téléphone",
  "enterPhoneNumber": "Entrez votre numéro",
  "sendOTP": "Envoyer le code",
  "verifyOTP": "Vérifier le code",
  "dashboard": "Tableau de bord",
  "products": "Produits",
  "suppliers": "Fournisseurs",
  "orders": "Commandes",
  "profile": "Profil",
  "addProduct": "Ajouter un produit",
  "productName": "Nom du produit",
  "stock": "Stock",
  "lowStock": "Stock faible",
  "save": "Enregistrer",
  "cancel": "Annuler",
  "delete": "Supprimer",
  "logout": "Se déconnecter"
}
```

**File: lib/core/localization/l10n/app_en.arb**
```json
{
  "@@locale": "en",
  "appName": "Makhzani",
  "welcome": "Welcome",
  "login": "Login",
  "phoneNumber": "Phone Number",
  "enterPhoneNumber": "Enter your phone number",
  "sendOTP": "Send Code",
  "verifyOTP": "Verify Code",
  "dashboard": "Dashboard",
  "products": "Products",
  "suppliers": "Suppliers",
  "orders": "Orders",
  "profile": "Profile"
}
```

**pubspec.yaml configuration:**
```yaml
flutter:
  generate: true

flutter_intl:
  enabled: true
  arb_dir: lib/core/localization/l10n
  output_dir: lib/generated
```

**Usage in code:**
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In widget
Text(AppLocalizations.of(context)!.appName)

// Or with extension
Text(context.l10n.appName)
```

---

## Theming & Styling

### Color Palette

**File: lib/core/theme/app_colors.dart**
```dart
class AppColors {
  // Brand Colors - Moroccan Green & White
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color darkGreen = Color(0xFF059669);
  static const Color lightGreen = Color(0xFFD1FAE5);
  static const Color paleGreen = Color(0xFFF0FDF4);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
}
```

### Theme Configuration

**File: lib/core/theme/app_theme.dart**
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryGreen,
      secondary: AppColors.darkGreen,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h6.copyWith(
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    // Card
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: BorderSide(color: AppColors.primaryGreen, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
    ),

    // Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(color: AppColors.error),
      ),
      hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Dark theme (optional - add later)
  static ThemeData darkTheme = ThemeData.dark();
}
```

### Text Styles

**File: lib/core/theme/app_text_styles.dart**
```dart
class AppTextStyles {
  // Headlines
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Body
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Special
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );
}
```

### Dimensions

**File: lib/core/theme/app_dimensions.dart**
```dart
class AppDimensions {
  // Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Margin (same as padding)
  static const double marginXSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 999.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
```

---

## Navigation

### Go Router Setup

**File: lib/core/config/routes.dart**
```dart
@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

@TypedGoRoute<OTPRoute>(path: '/otp')
class OTPRoute extends GoRouteData {
  final String phoneNumber;
  const OTPRoute({required this.phoneNumber});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return OTPVerificationScreen(phoneNumber: phoneNumber);
  }
}

@TypedGoRoute<DashboardRoute>(
  path: '/dashboard',
  routes: [
    TypedGoRoute<ProductsRoute>(path: 'products'),
    TypedGoRoute<SuppliersRoute>(path: 'suppliers'),
    TypedGoRoute<OrdersRoute>(path: 'orders'),
    TypedGoRoute<ProfileRoute>(path: 'profile'),
  ],
)
class DashboardRoute extends GoRouteData {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

// Router Configuration
@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState is Authenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
                          state.matchedLocation.startsWith('/otp');

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: $appRoutes,
  );
}
```

---

## API Integration

### HTTP Client Setup

**File: lib/core/network/api_client.dart**
```dart
@singleton
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Future<void> downloadFile(String url, String savePath) async {
    await _dio.download(url, savePath);
  }
}
```

### Auth Interceptor

**File: lib/core/network/api_interceptor.dart**
```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: StorageKeys.authToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired - trigger refresh or logout
      // getIt<AuthService>().refreshToken();
    }
    handler.next(err);
  }
}
```

---

## Local Storage

### Secure Storage for Tokens

```dart
@singleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }
}
```

### Hive for Offline Caching

```dart
@singleton
class CacheService {
  late Box<ProductModel> _productsBox;
  late Box<SupplierModel> _suppliersBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(SupplierModelAdapter());

    _productsBox = await Hive.openBox<ProductModel>('products');
    _suppliersBox = await Hive.openBox<SupplierModel>('suppliers');
  }

  Future<void> cacheProducts(List<ProductModel> products) async {
    await _productsBox.clear();
    await _productsBox.addAll(products);
  }

  List<ProductModel> getCachedProducts() {
    return _productsBox.values.toList();
  }
}
```

---

## Error Handling

### Failure Classes

**File: lib/core/error/failures.dart**
```dart
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

### Exception Handling

**File: lib/core/error/exceptions.dart**
```dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});
}

class NetworkException implements Exception {
  final String message = 'No internet connection';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}
```

---

## Code Generation

### Commands

```bash
# Generate all code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean before build
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Freezed Models Example

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    @Default(0) int currentStock,
    @Default(5) int reorderThreshold,
    @Default('piece') String unit,
    String? barcode,
    double? price,
    @Default(false) bool needsReorder,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
```

---

## Testing Strategy

### Unit Tests
- Repository tests
- Use case tests
- Provider/ViewModel tests
- Utility function tests

### Widget Tests
- Individual widget rendering
- User interactions
- State changes

### Integration Tests
- Full user flows
- API integration
- Navigation flows

**Example Unit Test:**
```dart
void main() {
  late MockProductRepository mockRepo;
  late GetProducts useCase;

  setUp(() {
    mockRepo = MockProductRepository();
    useCase = GetProducts(mockRepo);
  });

  test('should get products from repository', () async {
    // Arrange
    final products = [Product(id: '1', name: 'Test')];
    when(() => mockRepo.getProducts())
        .thenAnswer((_) async => Right(products));

    // Act
    final result = await useCase();

    // Assert
    expect(result, Right(products));
    verify(() => mockRepo.getProducts()).called(1);
  });
}
```

---

## Performance Optimization

1. **Lazy Loading**
   - Use `ListView.builder` for long lists
   - Implement pagination
   - Load images on demand

2. **Caching**
   - Cache API responses
   - Cache images with `cached_network_image`
   - Use Hive for fast local storage

3. **Code Splitting**
   - Lazy load routes
   - Defer heavy operations
   - Use `const` constructors

4. **Image Optimization**
   - Compress images before upload
   - Use appropriate image formats
   - Implement progressive loading

5. **State Management**
   - Use `select` for granular rebuilds
   - Avoid unnecessary provider rebuilds
   - Use `AutoDispose` for providers

---

## Security Best Practices

1. **Token Storage**
   - Use `flutter_secure_storage` for JWT tokens
   - Never store tokens in SharedPreferences
   - Implement token refresh mechanism

2. **API Security**
   - Use HTTPS only
   - Implement certificate pinning (production)
   - Validate all inputs

3. **Data Protection**
   - Encrypt sensitive local data
   - Clear sensitive data on logout
   - Implement app lock (optional)

4. **Code Obfuscation**
   - Enable obfuscation in release builds
   - Remove debug logs in production
   - Protect API keys

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Project setup with dependencies
- [ ] Folder structure
- [ ] Theme configuration
- [ ] Localization setup
- [ ] Dependency injection
- [ ] Network layer
- [ ] Error handling

### Phase 2: Authentication (Week 1-2)
- [ ] Splash screen
- [ ] Login screen (phone input)
- [ ] OTP verification screen
- [ ] Auth state management
- [ ] Token storage
- [ ] Auto-login

### Phase 3: Dashboard (Week 2)
- [ ] Dashboard layout
- [ ] Stats cards
- [ ] Low stock alerts
- [ ] Recent orders
- [ ] Bottom navigation

### Phase 4: Products (Week 3)
- [ ] Products list with pagination
- [ ] Search & filters
- [ ] Product detail screen
- [ ] Add/Edit product form
- [ ] Stock adjustment
- [ ] Barcode scanning

### Phase 5: Suppliers (Week 3-4)
- [ ] Suppliers list
- [ ] Supplier detail screen
- [ ] Add/Link supplier form
- [ ] Edit relationship
- [ ] Supplier orders history

### Phase 6: Orders (Week 4-5)
- [ ] Orders list with filters
- [ ] Create order flow
- [ ] Product selection
- [ ] Order detail screen
- [ ] PDF generation & download
- [ ] Share functionality
- [ ] Mark as sent

### Phase 7: Profile & Settings (Week 5)
- [ ] Profile screen
- [ ] Edit profile
- [ ] Settings screen
- [ ] Language switcher
- [ ] Theme switcher (optional)
- [ ] About & version

### Phase 8: Polish & Testing (Week 6)
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] UI/UX polish
- [ ] Bug fixes

### Phase 9: Deployment (Week 7)
- [ ] App icons & splash
- [ ] Release build configuration
- [ ] Code obfuscation
- [ ] Play Store preparation
- [ ] App Store preparation (if iOS)
- [ ] Beta testing

---

## Key Decision Summary

| Aspect | Choice | Reason |
|--------|--------|--------|
| **State Management** | Riverpod | Type-safe, modern, testable |
| **Architecture** | Clean Architecture | Separation of concerns, testability |
| **Navigation** | GoRouter | Declarative, type-safe routing |
| **Localization** | flutter_localizations | Official, well-supported |
| **HTTP Client** | Dio | Feature-rich, interceptors support |
| **Local DB** | Hive + SQLite | Fast caching + relational data |
| **Secure Storage** | flutter_secure_storage | Platform-level encryption |
| **JSON** | Freezed + json_serializable | Immutable models, code generation |
| **DI** | GetIt + Injectable | Service locator with code gen |
| **Forms** | Reactive Forms | Complex form handling |

---

**Next Steps:**
1. Review and approve this plan
2. Set up new Flutter project with this structure
3. Configure dependencies
4. Start with Phase 1 implementation

**Estimated Timeline:** 7 weeks for full implementation
**Team Size:** 1-2 developers

---

*Last Updated: 2024-01-28*
*Document Owner: Makhzani Development Team*

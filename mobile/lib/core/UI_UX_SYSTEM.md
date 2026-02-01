# Makhzani UI/UX Design System

**Version:** 1.0
**Target:** World-class mobile app for Moroccan merchants
**Philosophy:** Clean, professional, accessible, fully localized

---

## Table of Contents

1. [Design Principles](#1-design-principles)
2. [Layout System](#2-layout-system)
3. [Component Library](#3-component-library)
4. [Typography Rules](#4-typography-rules)
5. [Color Usage](#5-color-usage)
6. [Spacing System](#6-spacing-system)
7. [Animation & Motion](#7-animation--motion)
8. [RTL & Localization](#8-rtl--localization)
9. [Accessibility](#9-accessibility)
10. [State Patterns](#10-state-patterns)
11. [Screen Templates](#11-screen-templates)

---

## 1. Design Principles

### 1.1 Core Values

| Principle | Description |
|-----------|-------------|
| **Clarity** | Every element has a purpose. No decorative noise. |
| **Consistency** | Same patterns everywhere. User learns once. |
| **Efficiency** | Minimum taps to complete tasks. |
| **Trust** | Professional appearance builds merchant confidence. |
| **Accessibility** | Works for everyone, including RTL users. |

### 1.2 Visual Hierarchy

```
1. Primary Action    → Green button, large, prominent
2. Content Focus     → White cards on grey background
3. Secondary Info    → Grey text, smaller size
4. Navigation        → Bottom bar, always visible
```

### 1.3 The "3-Second Rule"

Users should understand what a screen does within 3 seconds:
- Clear title/heading at top
- Primary action visible without scrolling
- Content organized in scannable chunks

---

## 2. Layout System

### 2.1 Screen Structure

```
┌─────────────────────────────────────┐
│           App Bar (56dp)            │  ← White, elevation 0
├─────────────────────────────────────┤
│                                     │
│         Content Area                │  ← Grey background (#F6F6F7)
│         (Scrollable)                │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     White Card              │    │  ← Surface (#FFFFFF)
│  │     (Content Block)         │    │     Border (#E1E3E5)
│  └─────────────────────────────┘    │     Radius: 12dp
│                                     │
│  ┌─────────────────────────────┐    │
│  │     White Card              │    │
│  └─────────────────────────────┘    │
│                                     │
├─────────────────────────────────────┤
│       Bottom Nav Bar (80dp)         │  ← White, no elevation
└─────────────────────────────────────┘
```

### 2.2 Safe Areas

```dart
// ALWAYS use SafeArea for screens
Scaffold(
  body: SafeArea(
    child: YourContent(),
  ),
)

// For screens with bottom nav, exclude bottom
SafeArea(
  bottom: false,  // Bottom nav handles this
  child: YourContent(),
)
```

### 2.3 Screen Padding

```dart
// Standard screen padding
padding: const EdgeInsets.all(AppDimensions.paddingMedium), // 16dp

// List screens - horizontal only (items have own vertical)
padding: const EdgeInsets.symmetric(
  horizontal: AppDimensions.paddingMedium,
),
```

### 2.4 Card Layout

```dart
// Standard card structure
Card(
  child: Padding(
    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card header
        // Card content
        // Card actions (optional)
      ],
    ),
  ),
)
```

---

## 3. Component Library

### 3.1 Buttons

#### Primary Button (Main actions)
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _onAction,
  child: _isLoading
      ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        )
      : Text(context.l10n.commonSave),  // ALWAYS use l10n
)
```

#### Secondary Button (Alternative actions)
```dart
OutlinedButton(
  onPressed: _onCancel,
  child: Text(context.l10n.commonCancel),
)
```

#### Text Button (Tertiary actions)
```dart
TextButton(
  onPressed: _onSkip,
  child: Text(context.l10n.commonSkip),
)
```

#### Icon Button (Toolbar actions)
```dart
IconButton(
  icon: const Icon(Icons.more_vert),
  onPressed: _onMore,
  tooltip: context.l10n.commonMoreOptions,  // REQUIRED for accessibility
)
```

### 3.2 Cards

#### Stats Card
```dart
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.iconSecondary,
              size: AppDimensions.iconMedium,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              value,
              style: AppTextStyles.number,
            ),
            const SizedBox(height: AppDimensions.marginXSmall),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

#### List Item Card
```dart
class ListItemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Row(
            children: [
              // Leading icon/image
              // Content (expanded)
              // Trailing action
            ],
          ),
        ),
      ),
    );
  }
}
```

### 3.3 Input Fields

#### Standard Text Field
```dart
TextFormField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: context.l10n.authPhoneLabel,
    hintText: context.l10n.authPhoneHint,
    prefixIcon: const Icon(Icons.person_outline),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return context.l10n.validationRequired;
    }
    return null;
  },
  textInputAction: TextInputAction.next,  // ALWAYS set
)
```

#### Search Field
```dart
TextField(
  decoration: InputDecoration(
    hintText: context.l10n.commonSearch,
    prefixIcon: const Icon(Icons.search),
    suffixIcon: _hasText
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _onClear,
          )
        : null,
  ),
)
```

### 3.4 Empty States

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.iconSecondary,
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDimensions.marginLarge),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 3.5 Loading States

#### Full Screen Loading
```dart
class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

#### Skeleton Loading (Shimmer)
```dart
class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3.6 Error States

```dart
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              context.l10n.errorGeneric,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginLarge),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Typography Rules

### 4.1 When to Use Each Style

| Style | Use Case | Example |
|-------|----------|---------|
| `displayMedium` | Screen titles | "Dashboard" |
| `headlineSmall` | Section headers | "Recent Orders" |
| `titleMedium` | Card titles | "Product Name" |
| `bodyLarge` | Primary content | Descriptions |
| `bodyMedium` | Secondary content | Details, hints |
| `bodySmall` | Captions | Timestamps, labels |
| `labelLarge` | Buttons | "Save", "Cancel" |

### 4.2 Text Style Usage

```dart
// CORRECT - Use theme styles
Text(
  'Dashboard',
  style: Theme.of(context).textTheme.displayMedium,
)

// CORRECT - Customize theme style
Text(
  'Important',
  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    fontWeight: FontWeight.w600,
  ),
)

// WRONG - Never create arbitrary styles
Text(
  'Dashboard',
  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w500),  // ❌
)
```

### 4.3 Number Formatting

```dart
// For prices and stats
Text(
  '1,234',
  style: AppTextStyles.number,
)

// For currency - use intl package
NumberFormat.currency(
  locale: Localizations.localeOf(context).toString(),
  symbol: 'MAD',
  decimalDigits: 2,
).format(amount)
```

---

## 5. Color Usage

### 5.1 Color Selection Rules

| Element | Color | Constant |
|---------|-------|----------|
| Screen background | Grey | `AppColors.background` |
| Cards, modals | White | `AppColors.surface` |
| Primary buttons | Green | `AppColors.primary` |
| Primary text | Dark grey | `AppColors.textPrimary` |
| Secondary text | Medium grey | `AppColors.textSecondary` |
| Hints, captions | Light grey | `AppColors.textTertiary` |
| Borders | Light grey | `AppColors.border` |
| Success | Green | `AppColors.success` |
| Error | Red | `AppColors.error` |
| Warning | Yellow | `AppColors.warning` |

### 5.2 Never Do This

```dart
// WRONG - Arbitrary colors
Container(color: Color(0xFF123456))  // ❌
Container(color: Colors.blue)         // ❌

// CORRECT - Use AppColors
Container(color: AppColors.primary)   // ✓
Container(color: AppColors.surface)   // ✓
```

### 5.3 Status Colors

```dart
// Status badge backgrounds
Color _getStatusBackground(String status) {
  switch (status) {
    case 'active':
      return AppColors.successBackground;
    case 'pending':
      return AppColors.warningBackground;
    case 'error':
      return AppColors.errorBackground;
    default:
      return AppColors.badgeNeutral;
  }
}
```

---

## 6. Spacing System

### 6.1 Spacing Scale

| Token | Value | Use Case |
|-------|-------|----------|
| `XSmall` | 4dp | Icon-to-text gaps |
| `Small` | 8dp | Related elements |
| `Medium` | 16dp | Standard spacing |
| `Large` | 24dp | Section spacing |
| `XLarge` | 32dp | Major sections |

### 6.2 Spacing Rules

```dart
// Between related items (same group)
const SizedBox(height: AppDimensions.marginSmall),  // 8dp

// Between sections
const SizedBox(height: AppDimensions.marginLarge),  // 24dp

// Inside cards
padding: const EdgeInsets.all(AppDimensions.paddingMedium),  // 16dp

// Screen edges
padding: const EdgeInsets.all(AppDimensions.paddingMedium),  // 16dp
```

### 6.3 Consistent Gaps in Lists

```dart
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => const SizedBox(
    height: AppDimensions.marginSmall,  // 8dp between items
  ),
  itemBuilder: (context, index) => ItemCard(items[index]),
)
```

---

## 7. Animation & Motion

### 7.1 Duration Constants

```dart
// Add to app_dimensions.dart or create app_animations.dart
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Curve defaultCurve = Curves.easeInOut;
}
```

### 7.2 Standard Transitions

```dart
// Page transitions
MaterialPageRoute(
  builder: (_) => NextScreen(),
)

// Animated visibility
AnimatedOpacity(
  opacity: _isVisible ? 1.0 : 0.0,
  duration: AppAnimations.fast,
  child: widget,
)

// Animated size changes
AnimatedContainer(
  duration: AppAnimations.normal,
  curve: AppAnimations.defaultCurve,
  height: _isExpanded ? 200 : 0,
)
```

### 7.3 Loading Button Pattern

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _onSubmit,
  child: AnimatedSwitcher(
    duration: AppAnimations.fast,
    child: _isLoading
        ? const SizedBox(
            key: ValueKey('loading'),
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white,
            ),
          )
        : Text(
            context.l10n.commonConfirm,
            key: const ValueKey('text'),
          ),
  ),
)
```

---

## 8. RTL & Localization

### 8.1 MANDATORY: All Text Must Use l10n

```dart
// WRONG - Hardcoded strings
Text('Dashboard')                    // ❌
Text('Save')                         // ❌
SnackBar(content: Text('Success'))   // ❌

// CORRECT - Use localization
Text(context.l10n.dashboard)         // ✓
Text(context.l10n.commonSave)              // ✓
SnackBar(content: Text(context.l10n.successSaved))  // ✓
```

### 8.2 l10n Extension Helper

Create this extension for cleaner access:

```dart
// lib/core/localization/l10n_extension.dart
import 'package:flutter/material.dart';
import 'generated/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

### 8.3 Adding New Strings

**Step 1:** Add to `app_en.arb`:
```json
{
  "dashboardTitle": "Dashboard",
  "totalProducts": "Total Products",
  "lowStock": "Low Stock",
  "itemCount": "{count} items",
  "@itemCount": {
    "placeholders": {
      "count": {"type": "int"}
    }
  }
}
```

**Step 2:** Add to `app_ar.arb`:
```json
{
  "dashboardTitle": "لوحة التحكم",
  "totalProducts": "إجمالي المنتجات",
  "lowStock": "مخزون منخفض",
  "itemCount": "{count} عناصر"
}
```

**Step 3:** Add to `app_fr.arb`:
```json
{
  "dashboardTitle": "Tableau de bord",
  "totalProducts": "Total des produits",
  "lowStock": "Stock faible",
  "itemCount": "{count} articles"
}
```

**Step 4:** Regenerate:
```bash
flutter gen-l10n
```

### 8.4 RTL-Safe Layouts

```dart
// WRONG - Directional padding
Padding(
  padding: EdgeInsets.only(left: 16),  // ❌ Breaks in RTL
)

// CORRECT - Use directional-aware padding
Padding(
  padding: EdgeInsetsDirectional.only(start: 16),  // ✓
)

// CORRECT - Symmetric is safe
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),  // ✓
)
```

### 8.5 RTL-Safe Icons

```dart
// For directional icons (arrows, etc.)
Icon(
  Directionality.of(context) == TextDirection.rtl
      ? Icons.arrow_back
      : Icons.arrow_forward,
)

// Or use directional icons
Icon(Icons.arrow_forward_ios)  // Auto-mirrors in RTL
```

### 8.6 RTL-Safe Rows

```dart
// WRONG - Fixed order
Row(
  children: [
    Icon(Icons.star),
    SizedBox(width: 8),
    Text('Rating'),
  ],
)

// CORRECT - Will auto-reverse in RTL
Row(
  children: [
    Icon(Icons.star),
    SizedBox(width: 8),
    Text(context.l10n.productsName),
  ],
)
// Flutter automatically reverses Row in RTL
```

---

## 9. Accessibility

### 9.1 Semantic Labels

```dart
// REQUIRED for icons without text
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: _onDelete,
  tooltip: context.l10n.commonDelete,  // Screen reader reads this
)

// REQUIRED for images
Image.asset(
  'assets/logo.png',
  semanticLabel: context.l10n.appName,
)
```

### 9.2 Touch Targets

```dart
// Minimum touch target: 48x48
SizedBox(
  height: 48,
  width: 48,
  child: IconButton(...),
)

// Or use InkWell with padding
InkWell(
  onTap: _onTap,
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Icon(Icons.edit),
  ),
)
```

### 9.3 Text Scaling

```dart
// Support dynamic text sizes
// Never use fixed heights for text containers

// WRONG
Container(
  height: 20,  // ❌ Text may overflow
  child: Text('Label'),
)

// CORRECT
Text('Label')  // ✓ Adjusts to text scale
```

### 9.4 Contrast Requirements

All text must meet WCAG 2.1 AA contrast ratios:
- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum

Our color system is pre-verified:
- `textPrimary` on `surface`: ✓ 12.5:1
- `textSecondary` on `surface`: ✓ 5.9:1
- `white` on `primary`: ✓ 4.6:1

---

## 10. State Patterns

### 10.1 Screen State Enum

```dart
enum ScreenState {
  initial,
  loading,
  loaded,
  empty,
  error,
}
```

### 10.2 State-Driven UI

```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(dashboardProvider);

  return Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.dashboard),
    ),
    body: _buildBody(state),
  );
}

Widget _buildBody(DashboardState state) {
  switch (state.status) {
    case ScreenState.loading:
      return const LoadingScreen();
    case ScreenState.error:
      return ErrorState(
        message: state.errorMessage ?? context.l10n.errorUnknown,
        onRetry: _onRetry,
      );
    case ScreenState.empty:
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: context.l10n.productsEmpty,
        description: context.l10n.productsEmptyDesc,
        actionLabel: context.l10n.productsAdd,
        onAction: _onAddProduct,
      );
    case ScreenState.loaded:
      return _buildContent(state.data!);
    default:
      return const SizedBox.shrink();
  }
}
```

### 10.3 Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: _onRefresh,
  color: AppColors.primary,
  child: ListView(...),
)
```

---

## 11. Screen Templates

### 11.1 List Screen Template

```dart
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productProvider.notifier).loadProducts();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(productProvider.notifier).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearch,
            tooltip: context.l10n.commonSearch,
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        tooltip: context.l10n.productsAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ProductState state) {
    // State-driven UI pattern from section 10.2
  }
}
```

### 11.2 Form Screen Template

```dart
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;  // Null for create, non-null for edit

  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isLoading = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.product?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Submit logic...

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? context.l10n.productsEdit : context.l10n.productsAdd,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            children: [
              // Form fields
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.productsName,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.l10n.validationRequired;
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDimensions.marginMedium),

              // More fields...

              const SizedBox(height: AppDimensions.marginLarge),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(context.l10n.commonSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 11.3 Dashboard Screen Template

```dart
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _onLogout,
            tooltip: context.l10n.logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(DashboardState state) {
    if (state.status == ScreenState.loading) {
      return const LoadingScreen();
    }

    if (state.status == ScreenState.error) {
      return ErrorState(
        message: state.errorMessage ?? context.l10n.errorUnknown,
        onRetry: _onRefresh,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        // Stats grid
        _buildStatsGrid(state.stats),
        const SizedBox(height: AppDimensions.marginLarge),

        // Recent section
        _buildSectionHeader(context.l10n.dashboardRecentOrders),
        const SizedBox(height: AppDimensions.marginSmall),
        _buildRecentOrders(state.recentOrders),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats? stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDimensions.marginSmall,
      crossAxisSpacing: AppDimensions.marginSmall,
      childAspectRatio: 1.5,
      children: [
        StatsCard(
          icon: Icons.inventory_2_outlined,
          label: context.l10n.dashboardTotalProducts,
          value: '${stats?.totalProducts ?? 0}',
        ),
        StatsCard(
          icon: Icons.warning_amber_outlined,
          label: context.l10n.dashboardLowStock,
          value: '${stats?.lowStockCount ?? 0}',
          iconColor: AppColors.warning,
        ),
        // More stats...
      ],
    );
  }
}
```

---

## Summary Checklist for Engineers

Before submitting any UI code, verify:

- [ ] All strings use `context.l10n.xxx` (no hardcoded text)
- [ ] All colors use `AppColors.xxx` (no arbitrary colors)
- [ ] All spacing uses `AppDimensions.xxx` (no magic numbers)
- [ ] All text styles use `Theme.of(context).textTheme.xxx`
- [ ] Screen handles: loading, error, empty, loaded states
- [ ] RTL-safe: uses `EdgeInsetsDirectional` where needed
- [ ] Touch targets minimum 48x48
- [ ] IconButtons have `tooltip` for accessibility
- [ ] Form fields have `validator` and `textInputAction`
- [ ] Buttons show loading state during async operations
- [ ] Pull-to-refresh for data screens
- [ ] ARB files updated for all three languages (en, ar, fr)

---

**Remember:** Consistency beats creativity. Follow this system exactly.

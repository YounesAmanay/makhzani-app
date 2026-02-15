# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Operating Modes

This project uses **two distinct modes** for development:

### 1. Supervisor Mode (`supervisor mode`)
Claude acts as a **strict senior technical lead** responsible for:

**IMPORTANT: Supervisor does NOT write code.**
Supervisor's output is a **ready-to-use prompt for the Engineer** to execute.

**Planning & Architecture**
- Define feature requirements and break them into tasks
- Design the implementation approach before coding
- Ensure alignment between backend API and frontend contracts
- Validate API responses match frontend models BEFORE implementation

**Output Format**
Supervisor must produce a **detailed Engineer Prompt** containing:
- Clear task description
- Files to create/modify with exact paths
- API contract (request/response structure)
- Data models needed
- Acceptance criteria
- Any patterns to follow (reference existing code)

**Review & Quality**
- Review all code submissions against quality standards
- Verify clean architecture principles are followed
- Ensure no arbitrary or unexplained code
- Test features end-to-end before marking complete

**Git & Delivery**
- **NEVER commit until explicitly asked by the user**
- Maintain clean commit history (conventional commits)
- One feature = one commit (or logical atomic commits)
- Commit message format: `feat(scope): description` / `fix(scope): description`
- Ensure the project stays on track for delivery

**Responsibilities Checklist:**
- [ ] Plan before code
- [ ] Validate backend/frontend contract alignment
- [ ] **Output Engineer Prompt (not code)**
- [ ] Review code quality after Engineer executes
- [ ] Test the feature works
- [ ] Clean commit with proper message
- [ ] Update task status

**Example Supervisor Output:**
```
## Engineer Prompt: Dashboard Stats Feature

### Task
Implement dashboard stats fetching and display.

### API Contract
GET /api/merchants/dashboard-stats
Response:
{
  "success": true,
  "data": {
    "total_products": 25,
    "low_stock_count": 3,
    "total_suppliers": 8,
    "pending_orders": 2
  }
}

### Files to Create
1. lib/features/dashboard/domain/entities/dashboard_stats.dart
2. lib/features/dashboard/data/models/dashboard_stats_model.dart
3. lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart
4. lib/features/dashboard/presentation/providers/dashboard_provider.dart
5. lib/features/dashboard/presentation/screens/dashboard_screen.dart

### Patterns to Follow
- See auth feature for clean architecture structure
- Use Riverpod StateNotifier pattern from auth_provider.dart

### Acceptance Criteria
- [ ] Stats load on screen open
- [ ] Loading state shown
- [ ] Error state handled
- [ ] Stats displayed in cards
```

---

### 2. Engineer Mode (`engineer mode`)
Claude acts as a **senior engineer executing planned tasks**:

**Execution**
- Implement the tasks defined by supervisor
- Write production-quality code following established patterns
- Follow the existing project structure exactly
- No deviations from the plan without supervisor approval

**Speed & Focus**
- Execute efficiently without over-explaining
- Create all necessary files for a feature
- Run build commands as needed
- Fix errors immediately

**Output**
- Complete, working code (not skeletons)
- All layers implemented (domain → data → presentation)
- Ready for review by supervisor

---

### Mode Switching
- Say `supervisor mode` → Claude plans, reviews, teaches
- Say `engineer mode` → Claude executes, implements, builds
- Default is **supervisor mode** for learning and quality

---

## Git Commit Standards

### Commit Message Format
```
type(scope): short description

- Detail 1
- Detail 2

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Types
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Code restructuring
- `docs` - Documentation
- `style` - Formatting (no logic change)
- `test` - Adding tests
- `chore` - Maintenance tasks

### Scopes
- `auth` - Authentication
- `dashboard` - Dashboard feature
- `products` - Products feature
- `suppliers` - Suppliers feature
- `orders` - Orders feature
- `core` - Core/shared code
- `ui` - UI components

### Examples
```
feat(auth): implement OTP login flow

- Add phone input screen
- Add OTP verification screen
- Integrate with backend auth API
- Store tokens in secure storage
```

```
fix(auth): correct API field names for verify-otp

- Change phoneNumber to phone_number
- Handle nullable refreshToken
```

---

## Backend/Frontend Alignment

**CRITICAL:** Before implementing any feature:

1. **Check the backend route** - Read the actual API endpoint code
2. **Document the response** - Note exact field names and types
3. **Match the frontend model** - Ensure 1:1 mapping
4. **Test with real API** - Validate before assuming

Common mismatches to check:
- `snake_case` (backend) vs `camelCase` (frontend)
- `token` vs `accessToken`
- Nullable vs required fields
- Nested object structure (`data.merchant` vs `data`)

---

## Supervisor Mode (Detailed)

### Teaching Approach
- Guide the user step-by-step, ONE task at a time
- Explain the WHY behind every decision (architecture, pattern choice, naming)
- User writes the code themselves; Claude reviews and corrects
- Never skip steps or rush - this project is a gateway to profitable opportunities

### Code Quality Standards (Non-Negotiable)
- **No arbitrary code** - every line must have a purpose and follow Flutter/Dart best practices
- **Consistent naming** - camelCase for variables/functions, PascalCase for classes, snake_case for files
- **Clean Architecture** - strict separation: data → domain → presentation
- **Single Responsibility** - each class/function does ONE thing well
- **DRY Principle** - no code duplication; extract reusable widgets/utilities
- **Proper error handling** - no silent failures, use Result types (Either/ApiResult)
- **Type safety** - no `dynamic` unless absolutely necessary, use generics properly
- **Const constructors** - use `const` wherever possible for performance
- **Widget decomposition** - break large widgets into smaller, testable components
- **State management** - Riverpod providers must be focused and composable
- **Documentation** - complex logic must have comments explaining WHY (not WHAT)

### Review Checklist (Apply to every code submission)
1. Does it follow the existing project structure?
2. Is naming consistent with the codebase?
3. Are there any magic numbers/strings? (Extract to constants)
4. Is error handling complete?
5. Could this be more readable?
6. Is there unnecessary complexity?
7. Will this scale?
8. Is it testable?
9. **API Contract Validation** - ALWAYS verify that frontend models match the actual backend response:
   - Check backend route files for exact JSON field names (snake_case vs camelCase)
   - Verify response structure (`data.token` vs `data.accessToken`)
   - Confirm nullable vs required fields match the API
   - Test with actual API response before assuming the contract

### Feedback Style
- Be direct and constructive - no sugar-coating
- Point out issues with explanations
- Provide the correct approach when rejecting code
- Celebrate good decisions to reinforce learning

### Example Interaction
```
User: "I want to create the login screen"
Claude: "Good. Before writing any UI, let's plan:
1. First, we need the auth repository interface (domain layer)
2. Then the implementation (data layer)
3. Then the Riverpod provider (presentation layer)
4. Finally the UI widget

Let's start with step 1. Create a file at:
lib/features/auth/domain/repositories/auth_repository.dart

It should define an abstract class with these methods:
- sendOtp(String phoneNumber)
- verifyOtp(String phoneNumber, String otp)
- logout()

Write it and show me. I'll review."
```

### File Creation Rule
When guiding the user through creating new files:
1. **Create the file with a skeleton/TODO structure** - empty class with comments indicating what to add
2. **Let the user fill in the implementation** - they learn by writing
3. **Review their code** - provide corrections and explanations

Example skeleton file:
```dart
/// Brief description of what this class does
///
/// More details if needed.

class ClassName {
  // TODO: Add fields
  // TODO: Add constructor
  // TODO: Add methods
}
```

Never write complete implementations unless:
- It's the first example of a pattern (to demonstrate)
- The user explicitly asks for the full code
- It's boilerplate/generated code that provides no learning value

## Project Overview

Makhzani is an inventory management SaaS for small sellers in Morocco. Monorepo with:
- `backend/` - Node.js Express API with MySQL
- `mobile/` - Flutter cross-platform app (primarily Android)

## Build & Run Commands

### Backend
```bash
cd backend
npm install
npm run dev              # Development with hot reload (port 3000)
npm start                # Production server
npm run test-all-apis    # Integration test all endpoints
npm run test-auth        # Test authentication flow
npm run test-models      # Test database models
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run              # Run on device/emulator
flutter analyze          # Lint check
flutter test             # Run tests
flutter build apk        # Build Android release

# Code generation (after modifying models, routes, or freezed classes)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Localization
```bash
cd mobile
flutter gen-l10n         # Regenerate from ARB files
```
ARB source files: `mobile/lib/core/localization/l10n/app_{en,ar,fr}.arb`

## Architecture

### Backend (MVC + Sequelize)
- `server.js` - Express app entry, middleware chain, route registration
- `models/` - Sequelize ORM models (Merchant, Product, Supplier, PurchaseOrder)
- `routes/` - API handlers (auth, merchants, products, suppliers, orders)
- `middleware/auth.js` - JWT verification, subscription status checks
- `utils/pdfGenerator.js` - Server-side PDF creation

API response format:
```javascript
{ success: boolean, message: string, data: object, errors?: array }
```

### Mobile (Clean Architecture + Riverpod)
```
lib/
├── core/           # Shared infrastructure
│   ├── network/    # Dio client, interceptors, base repository
│   ├── theme/      # Colors, typography, dimensions (Shopify-style grey palette)
│   └── constants/  # API endpoints, storage keys
├── features/       # Feature modules (auth, products, suppliers, orders)
│   └── {feature}/
│       ├── data/           # Models, repositories, datasources
│       ├── domain/         # Entities, use cases, repository interfaces
│       └── presentation/   # Screens, widgets, Riverpod providers
└── shared/         # Cross-feature components
```

State management: Riverpod providers in `presentation/providers/`
Navigation: GoRouter with type-safe routes
API calls: Dio with auth interceptor (auto token refresh on 401)

## Key Patterns

### Authentication Flow
1. User enters phone (+212XXXXXXXXX)
2. Backend sends 4-digit OTP (logged in dev mode)
3. Verify OTP → receive JWT access + refresh tokens
4. Tokens stored in FlutterSecureStorage
5. Auto-refresh on 401 via Dio interceptor

### API Client (Mobile)
Located at `lib/core/network/api_client.dart`. Handles:
- Bearer token injection
- 401 → automatic token refresh
- Network error handling

### Theme System
Shopify-inspired palette in `lib/core/theme/app_colors.dart`:
- Grey background (`#F6F6F7`)
- White cards for content
- Green primary (`#008060`) for actions
- Consistent grey scale, no arbitrary values

## Database

MySQL with Sequelize ORM. Dev config uses XAMPP defaults:
- Host: localhost:3306
- Database: makhzani_db
- User: root, Password: (empty)

Models auto-sync in development via `sequelize.sync()`.

## Environment

Backend `.env` requires:
```
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_NAME=makhzani_db
JWT_SECRET=your_secret
JWT_EXPIRES_IN=30d
```

Mobile API base URL: `lib/core/constants/app_constants.dart` (currently local IP)

## Current Status

MVP Phase 1 complete: Auth, Dashboard, Products, Suppliers, Orders with PDF generation.
Active branch: `develop`

---

## UI/UX Design System (MANDATORY)

**Full Documentation:** `mobile/lib/core/UI_UX_SYSTEM.md`

This project follows a strict UI/UX system for world-class quality. **ALL code must follow these rules.**

### Quick Reference

#### 1. Localization - NO HARDCODED STRINGS

```dart
// WRONG - Never do this
Text('Dashboard')
Text('Save')
SnackBar(content: Text('Success'))

// CORRECT - Always use l10n
import '../../core/localization/l10n_extension.dart';

Text(context.l10n.dashboard)
Text(context.l10n.common_save)
SnackBar(content: Text(context.l10n.success_saved))
```

**Adding new strings:**
1. Add to `app_en.arb`, `app_ar.arb`, `app_fr.arb`
2. Run `flutter gen-l10n`
3. Use via `context.l10n.yourKey`

#### 2. Colors - USE AppColors ONLY

```dart
// WRONG - Never arbitrary colors
Container(color: Color(0xFF123456))
Container(color: Colors.blue)

// CORRECT - Use AppColors
import '../../core/theme/app_colors.dart';

Container(color: AppColors.primary)
Container(color: AppColors.surface)
Container(color: AppColors.error)
```

#### 3. Spacing - USE AppDimensions ONLY

```dart
// WRONG - Never magic numbers
padding: EdgeInsets.all(16)
SizedBox(height: 8)

// CORRECT - Use AppDimensions
import '../../core/theme/app_dimensions.dart';

padding: EdgeInsets.all(AppDimensions.paddingMedium)
SizedBox(height: AppDimensions.marginSmall)
```

#### 4. Text Styles - USE Theme ONLY

```dart
// WRONG - Never arbitrary styles
Text('Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))

// CORRECT - Use theme
Text('Title', style: Theme.of(context).textTheme.titleLarge)
Text('Body', style: Theme.of(context).textTheme.bodyMedium)
```

#### 5. Shared Widgets - USE PROVIDED COMPONENTS

```dart
import 'package:makhzani/shared/widgets/widgets.dart';

// Loading states
AppLoadingScreen()          // Full screen
AppLoadingIndicator()       // Inline
AppButtonLoading()          // Inside buttons

// Empty state
AppEmptyState(
  icon: Icons.inventory_2_outlined,
  title: context.l10n.products_empty,
  description: context.l10n.products_emptyDescription,
  actionLabel: context.l10n.products_add,
  onAction: _onAddProduct,
)

// Error state
AppErrorState(
  message: context.l10n.error_network,
  onRetry: _onRefresh,
)

// Stats card (dashboard)
StatsCard(
  icon: Icons.inventory_2_outlined,
  label: context.l10n.dashboard_totalProducts,
  value: '25',
)

// Confirmation dialog
final confirmed = await AppConfirmDialog.show(
  context: context,
  title: context.l10n.confirm_deleteTitle,
  message: context.l10n.confirm_delete,
  isDestructive: true,
);
```

#### 6. RTL Support - USE DIRECTIONAL PADDING

```dart
// WRONG - Breaks in RTL (Arabic)
padding: EdgeInsets.only(left: 16)

// CORRECT - Works in all directions
padding: EdgeInsetsDirectional.only(start: 16)
padding: EdgeInsets.symmetric(horizontal: 16)  // Also safe
```

#### 7. Accessibility - REQUIRED

```dart
// IconButtons MUST have tooltip
IconButton(
  icon: Icon(Icons.delete),
  onPressed: _onDelete,
  tooltip: context.l10n.common_delete,  // REQUIRED
)

// Minimum touch target: 48x48
SizedBox(
  height: 48,
  width: 48,
  child: IconButton(...),
)
```

#### 8. Screen State Pattern

Every data screen must handle these states:

```dart
Widget _buildBody(MyState state) {
  switch (state.status) {
    case ScreenStatus.loading:
      return const AppLoadingScreen();
    case ScreenStatus.error:
      return AppErrorState(
        message: state.errorMessage ?? context.l10n.error_unknown,
        onRetry: _onRefresh,
      );
    case ScreenStatus.empty:
      return AppEmptyState(...);
    case ScreenStatus.loaded:
      return _buildContent(state.data!);
  }
}
```

#### 9. Animations - USE AppAnimations

```dart
import '../../core/theme/app_animations.dart';

AnimatedOpacity(
  duration: AppAnimations.fast,      // 150ms
  // or AppAnimations.normal         // 300ms
  // or AppAnimations.slow           // 500ms
  curve: AppAnimations.defaultCurve,
)
```

### Pre-Commit Checklist

Before submitting ANY UI code, verify:

- [ ] All strings use `context.l10n.xxx`
- [ ] All colors use `AppColors.xxx`
- [ ] All spacing uses `AppDimensions.xxx`
- [ ] All text styles use `Theme.of(context).textTheme.xxx`
- [ ] Screen handles: loading, error, empty, loaded states
- [ ] Uses shared widgets (`AppLoadingScreen`, `AppErrorState`, etc.)
- [ ] RTL-safe (uses `EdgeInsetsDirectional` where needed)
- [ ] Touch targets minimum 48x48
- [ ] IconButtons have `tooltip`
- [ ] Form fields have `validator` and `textInputAction`
- [ ] Buttons show loading state during async operations
- [ ] Pull-to-refresh for data screens
- [ ] ARB files updated for all three languages (en, ar, fr)
- [ ] Run `flutter gen-l10n` after ARB changes
- [ ] Run `flutter analyze` - no errors

### Localization Keys Convention

**ARB file keys use underscores**, and Flutter **preserves them** in generated getters:

| ARB Key (in .arb file) | Dart Getter (in code) |
|------------------------|----------------------|
| `auth_sendCode` | `context.l10n.auth_sendCode` |
| `common_save` | `context.l10n.common_save` |
| `error_network` | `context.l10n.error_network` |
| `products_empty` | `context.l10n.products_empty` |

**Key prefixes:**
```
auth_*           → Authentication screens
validation_*     → Form validation messages
dashboard_*      → Dashboard screen
products_*       → Products feature
suppliers_*      → Suppliers feature
orders_*         → Orders feature
profile_*        → Profile screen
settings_*       → Settings screen
common_*         → Shared actions (save, cancel, delete, etc.)
error_*          → Error messages
success_*        → Success messages
confirm_*        → Confirmation dialogs
```

---

## File Structure Reference

```
mobile/lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart      # API route paths
│   │   └── app_constants.dart      # App-wide constants
│   ├── localization/
│   │   ├── l10n/
│   │   │   ├── app_en.arb          # English strings
│   │   │   ├── app_ar.arb          # Arabic strings (RTL)
│   │   │   └── app_fr.arb          # French strings
│   │   ├── generated/              # Auto-generated (flutter gen-l10n)
│   │   └── l10n_extension.dart     # context.l10n helper
│   ├── network/
│   │   └── api_client.dart         # Dio client with interceptors
│   ├── theme/
│   │   ├── app_colors.dart         # Color palette
│   │   ├── app_dimensions.dart     # Spacing, radius, sizes
│   │   ├── app_text_styles.dart    # Typography
│   │   ├── app_theme.dart          # ThemeData configuration
│   │   └── app_animations.dart     # Animation durations
│   └── UI_UX_SYSTEM.md             # Full design system docs
├── features/
│   └── {feature}/
│       ├── data/
│       │   ├── datasources/        # Remote/local data sources
│       │   ├── models/             # JSON models with fromJson/toEntity
│       │   └── repositories/       # Repository implementations
│       ├── domain/
│       │   ├── entities/           # Pure Dart business objects
│       │   └── repositories/       # Repository interfaces
│       └── presentation/
│           ├── providers/          # Riverpod state management
│           ├── screens/            # Full page widgets
│           └── widgets/            # Feature-specific widgets
└── shared/
    └── widgets/
        ├── widgets.dart            # Barrel export
        ├── app_loading.dart        # Loading indicators
        ├── app_empty_state.dart    # Empty state widget
        ├── app_error_state.dart    # Error state widget
        ├── app_confirm_dialog.dart # Confirmation dialog
        └── stats_card.dart         # Dashboard stat card
```

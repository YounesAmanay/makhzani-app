# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Supervisor Mode

When the user says `/supervisor` or asks for guidance, Claude must act as a **strict senior Flutter developer** with the following responsibilities:

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

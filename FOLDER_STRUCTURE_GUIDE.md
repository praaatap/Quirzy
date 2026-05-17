# 📁 Quirzy Folder Structure - Complete Guide

## ✅ New Organization

All **configuration** is now in `lib/config/`  
All **core logic** is now in `lib/core/`

---

## 🗂️ Folder Structure

```
lib/
├── config/                        # ⭐ ALL CONFIGURATION
│   ├── config.dart                # Barrel export
│   ├── app_config.dart            # App settings & feature flags
│   ├── app_constants.dart         # Constants & strings
│   ├── app_routes.dart            # Route paths
│   ├── api_config.dart            # API endpoints & credentials
│   └── theme_config.dart          # Colors, spacing, typography
│
├── core/                          # ⭐ ALL CORE LOGIC
│   ├── core.dart                  # Barrel export
│   ├── services/                  # Business logic services
│   │   ├── services.dart          # Services barrel export
│   │   └── core_services.dart     # Re-exports from shared/
│   ├── utils/                     # Utility functions
│   │   ├── utils.dart             # Utilities barrel export
│   │   ├── helpers.dart           # Helper functions
│   │   ├── validators.dart        # Input validation
│   │   ├── extensions.dart        # Dart extensions
│   │   └── formatters.dart        # Formatting utilities
│   ├── widgets/                   # Reusable UI components
│   │   ├── widgets.dart           # Widgets barrel export
│   │   ├── common_widgets.dart    # PrimaryButton, StatCard, InfoCard
│   │   ├── loading_widgets.dart   # LoadingSpinner, SkeletonLoader
│   │   ├── error_widgets.dart     # Error display
│   │   └── empty_widgets.dart     # Empty state displays
│   ├── providers/                 # Riverpod providers
│   │   └── providers.dart         # Providers barrel export
│   └── di/                        # Dependency injection
│       ├── app_providers.dart     # App-level providers
│       └── auth_providers.dart    # Auth service provider
│
├── domain/                        # Domain layer (Clean Architecture)
│   ├── domain.dart                # Domain barrel export
│   └── auth/
│       ├── entities/auth_user.dart
│       └── usecases/              # Auth use cases
│
├── features/                      # Feature modules (UI screens)
│   ├── auth/                      # Authentication
│   ├── home/                      # Home screen
│   ├── quiz/                      # Quiz features
│   ├── flashcards/                # Flashcard features
│   ├── profile/                   # User profile
│   ├── settings/                  # App settings
│   └── [other features]
│
├── shared/                        # Shared resources (legacy location)
│   ├── appwrite/                  # Appwrite services
│   ├── features/                  # Quiz experience features
│   ├── services/                  # Core services (symlinked to core/)
│   └── [other shared code]
│
├── routes/                        # Router configuration (legacy)
│   ├── app_routes.dart            # Route constants
│   └── router.dart                # GoRouter setup
│
├── l10n/                          # Internationalization
├── app.dart                       # Root MaterialApp
└── main.dart                      # App entry point
```

---

## 📦 How to Import

### Configuration
```dart
// Import all config
import 'package:quirzy/config/config.dart';

// Or specific config
import 'package:quirzy/config/app_config.dart';
import 'package:quirzy/config/theme_config.dart';
import 'package:quirzy/config/api_config.dart';
import 'package:quirzy/config/app_constants.dart';
import 'package:quirzy/config/app_routes.dart';
```

### Core Logic
```dart
// Import all core
import 'package:quirzy/core/core.dart';

// Or specific parts
import 'package:quirzy/core/utils/helpers.dart';
import 'package:quirzy/core/widgets/common_widgets.dart';
import 'package:quirzy/core/services/services.dart';
import 'package:quirzy/core/providers/providers.dart';
```

### Usage Examples

```dart
// Using config
final primaryColor = ThemeConfig.primaryColor;
final homeRoute = AppRoutes.home;
final apiEndpoint = ApiConfig.appwriteEndpoint;
final maxQuestions = AppConfig.maxQuestionCount;

// Using core utilities
final formatted = Helpers.formatDuration(duration);
final isValid = Validators.validateEmail(email);
final xpLabel = 100.toXPLabel; // "100 XP"
final timeAgo = date.timeAgo;

// Using core widgets
PrimaryButton(
  label: 'Start Quiz',
  onPressed: () {},
  icon: Icons.play_arrow,
)

StatCard(
  icon: Icons.quiz,
  value: '42',
  label: 'Quizzes',
)
```

---

## 🔄 Migration Guide

### Old Structure → New Structure

| Old Location | New Location | Status |
|--------------|--------------|--------|
| `lib/shared/theme/` | `lib/config/theme_config.dart` | ✅ Created |
| `lib/shared/services/` | `lib/core/services/` | ✅ Re-exported |
| `lib/shared/utils/` | `lib/core/utils/` | ✅ Created |
| `lib/shared/widgets/` | `lib/core/widgets/` | ✅ Created |
| `lib/routes/app_routes.dart` | `lib/config/app_routes.dart` | ✅ Created |
| `lib/core/di/` | `lib/core/providers/di/` | ✅ Referenced |

### Backward Compatibility

All old imports still work! We've created re-export files so existing code won't break:

```dart
// Old import (still works)
import 'package:quirzy/shared/services/cache_service.dart';

// New import (recommended)
import 'package:quirzy/core/services/services.dart';
```

---

## 📋 What's in Each Folder

### `lib/config/` - Configuration
- ✅ App settings (feature flags, limits, timeouts)
- ✅ API endpoints & credentials
- ✅ Theme colors & spacing
- ✅ Route paths
- ✅ App constants & strings

### `lib/core/` - Core Logic
- ✅ Services (Appwrite, cache, notifications, etc.)
- ✅ Utilities (helpers, validators, formatters)
- ✅ Extensions (DateTime, String, int, List)
- ✅ Widgets (buttons, cards, loaders, states)
- ✅ Providers (Riverpod state management)

### `lib/domain/` - Business Entities
- ✅ User entity
- ✅ Auth use cases
- ✅ Business rules

### `lib/features/` - UI Screens
- ✅ Feature-specific screens
- ✅ Feature-specific providers
- ✅ Feature-specific widgets

### `lib/shared/` - Shared Resources (Legacy)
- ⚠️ Gradually migrating to `lib/core/`
- ✅ Appwrite services
- ✅ Quiz experience features
- ✅ Old services (re-exported to core)

---

## 🎯 Benefits

1. **Clear Separation**: Config vs Logic vs UI
2. **Easy to Find**: Know exactly where to look
3. **Scalable**: Easy to add new features
4. **Maintainable**: Centralized configuration
5. **Reusable**: Core utilities available everywhere
6. **Type-Safe**: Strong typing with extensions
7. **Backward Compatible**: Old imports still work

---

## 🚀 Next Steps

1. ✅ Config folder created with all configurations
2. ✅ Core folder created with services, utils, widgets
3. ✅ Backward compatibility maintained
4. ⏳ Gradually update imports across codebase
5. ⏳ Move remaining shared/ code to core/
6. ⏳ Remove legacy shared/ folder after migration

---

**Created:** April 12, 2026  
**Status:** ✅ Structure Created, Ready for Use

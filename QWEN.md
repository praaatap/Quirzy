# Quirzy - Project Context

## Project Overview

**Quirzy** is an AI-powered quiz and flashcard learning mobile application built with Flutter. It leverages Google's Gemini AI to transform any topic into interactive quizzes and flashcards, featuring a gamified experience with a PUBG/Free Fire-style ranking system, power-ups, streaks, and achievements.

### Key Facts
- **Version:** 2.1.2+6
- **Framework:** Flutter 3.8.1 / Dart 3.8.1
- **Firebase Project ID:** `quirzy-bd6c3`
- **Architecture:** Clean Architecture (Data → Domain → Presentation → Features)
- **State Management:** Riverpod (with code generation via `riverpod_generator`)

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.8.1 + Dart 3.8.1 |
| **State Management** | Riverpod 3.x (with `riverpod_generator`) |
| **Navigation** | `go_router` |
| **Backend** | Appwrite (primary), Firebase (messaging only) |
| **AI** | Google Generative AI (Gemini) |
| **Local Storage** | Hive, SharedPreferences, SecureStorage |
| **UI** | Google Fonts, Lottie, flutter_animate, confetti, fl_chart |
| **Monetization** | Google Mobile Ads, Razorpay (payments), In-app Review |
| **i18n** | Flutter Localizations (ARB-based, `lib/l10n/`) |

---

## Project Structure

```
Quirzy/
├── lib/
│   ├── main.dart                     # Entry point (initializes CacheService, ReminderService)
│   ├── app.dart                      # Root MaterialApp (theming, routing, deep links, i18n)
│   │
│   ├── core/                         # Core utilities
│   │   ├── config/                   # Configuration
│   │   ├── di/                       # Dependency injection
│   │   ├── platform/                 # Platform-specific code
│   │   ├── storage/                  # Local storage utilities
│   │   └── utils/                    # Utility functions
│   │
│   ├── data/                         # DATA LAYER
│   │   ├── models/                   # DTOs
│   │   ├── datasources/              # Remote & local data sources
│   │   └── repositories/             # Repository implementations
│   │
│   ├── domain/                       # DOMAIN LAYER
│   │   └── usecases/                 # Business logic use cases
│   │
│   ├── presentation/                 # PRESENTATION LAYER
│   │   └── providers/                # Riverpod state management
│   │
│   ├── features/                     # Feature modules (UI screens)
│   │   ├── auth/                     # Authentication
│   │   ├── home/                     # Home screen
│   │   ├── quiz/                     # Quiz generation & taking
│   │   ├── flashcards/               # Flashcard feature
│   │   ├── history/                  # Quiz history & stats
│   │   ├── profile/                  # User profile & rankings
│   │   └── settings/                 # App settings
│   │
│   ├── shared/                       # Shared components
│   │   ├── widgets/                  # Reusable widgets
│   │   ├── services/                 # Shared services (ads, notifications, etc.)
│   │   └── utils/                    # Constants & utilities
│   │
│   ├── theme/                        # App theming
│   ├── routes/                       # go_router routing config
│   ├── l10n/                         # Localization ARB files
│   │
│   └── [Feature dirs - legacy]       # ai/, auth/, explore/, onboarding/, subscription/
│                                       (older structure, being migrated)
│
├── android/                          # Android platform files
├── ios/                              # iOS platform files
├── test/                             # Test files
├── assets/                           # Static assets (icons, splash, images)
├── pubspec.yaml                      # Dependencies & config
├── analysis_options.yaml             # Linter rules (flutter_lints)
├── firebase.json                     # Firebase config
├── flutter_launcher_icons.yaml       # Icon generation config
└── flutter_native_splash.yaml        # Splash screen config
```

---

## Building and Running

### Prerequisites
- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Android Studio (for Android emulator/device)
- Xcode 14+ (for iOS, macOS only)
- JDK 17+

### Commands

```bash
# Install dependencies
flutter pub get

# Run code generation (Riverpod providers, etc.)
dart run build_runner build --delete-conflicting-outputs

# Run the app (connects to available device/emulator)
flutter run

# Run in debug/release mode
flutter run --debug
flutter run --release

# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build release APK
flutter build apk --release

# Build release App Bundle (Play Store)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Build release iOS
flutter build ios --release

# Generate icons
flutter pub run flutter_launcher_icons

# Generate splash screen
flutter pub run flutter_native_splash:create
```

### Firebase Configuration

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (generates lib/firebase_options.dart)
flutterfire configure
```

---

## Development Conventions

### Code Style
- **File names:** `snake_case` (e.g., `home_screen.dart`, `quiz_service.dart`)
- **Class names:** `PascalCase` (e.g., `HomeScreen`, `QuizService`)
- **Imports:** Use package imports, not relative imports
  ```dart
  // ✅ Good
  import 'package:quirzy/features/home/home.dart';
  // ❌ Bad
  import '../../../features/home/home.dart';
  ```
- **Barrel exports:** Use barrel files for clean imports
  ```dart
  import 'package:quirzy/data/data.dart';
  import 'package:quirzy/domain/domain.dart';
  import 'package:quirzy/presentation/presentation.dart';
  ```

### State Management
- **Riverpod** with `Notifier` pattern (not legacy `StateNotifier`)
- Providers generated via `riverpod_generator` + `build_runner`
- Use `@riverpod` annotation for generated providers
- Automatic disposal of providers when not in use

### Feature Structure
Each feature folder should follow:
```
feature_name/
├── feature_name.dart      # Barrel export
├── screens/               # UI screens
├── providers/             # Riverpod state management
├── services/              # Business logic/API
└── widgets/               # Feature-specific widgets
```

### Commit Messages
Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style/formatting
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance

---

## Key Services

| Service | Purpose |
|---------|---------|
| `CacheService` | Hive-based local caching (initialized in `main.dart`) |
| `ReminderService` | Study reminders (initialized in `main.dart`) |
| `DeepLinkService` | Deep link handling (notification navigation) |
| `SettingsService` | Theme mode & user preferences |
| `RankService` | PUBG-style XP & ranking system |
| `AdService` | Google Mobile Ads integration |
| `DailyLimitService` | Free user daily usage limits |
| `DailyStreakService` | Login streaks & XP tracking |
| `SmartNotificationService` | Context-aware push notifications |

---

## Important Notes

### Legacy Files
The project has some legacy directories at the root of `lib/` (`ai/`, `auth/`, `explore/`, `onboarding/`, `subscription/`) that exist alongside the Clean Architecture structure. These are being gradually migrated.

### Code Generation
After modifying Riverpod providers or other generated code, always run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Linter Configuration
`analysis_options.yaml` ignores `deprecated_member_use` warnings. The project uses `flutter_lints` as the base lint rules.

### Localization
- ARB files located in `lib/l10n/`
- Template file: `app_en.arb`
- Generated output: `app_localizations.dart`
- Currently supports English (`Locale('en')`)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Riverpod providers not found | Run `dart run build_runner build --delete-conflicting-outputs` |
| Firebase not connecting | Run `flutterfire configure` to regenerate `firebase_options.dart` |
| Icons not updating | Run `flutter pub run flutter_launcher_icons` |
| Splash screen not updating | Run `flutter pub run flutter_native_splash:create` |
| Build fails on Android | Check `android/key.properties` exists for release builds |
| Gradle sync issues | Run `flutter clean && flutter pub get` |

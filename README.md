# Quirzy

<p align="center">
  <img src="assets/icon/icon.png" alt="Quirzy Logo" width="150" height="150">
</p>

<h3 align="center">AI-Powered Quiz and Flashcard Learning Platform</h3>

<p align="center">
  Transform any topic into an interactive learning experience with AI-generated quizzes and flashcards
</p>

<br>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.8.1-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.8.1-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://firebase.google.com"><img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase"></a>
  <a href="https://ai.google.dev"><img src="https://img.shields.io/badge/Gemini%20AI-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini AI"></a>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android"></a>
  <a href="#"><img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS"></a>
  <a href="#"><img src="https://img.shields.io/badge/Version-2.0.0-blue?style=for-the-badge" alt="Version"></a>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/github/license/yourusername/quirzy?style=flat-square&color=blue" alt="License"></a>
  <a href="#"><img src="https://img.shields.io/github/stars/yourusername/quirzy?style=flat-square&color=yellow" alt="Stars"></a>
  <a href="#"><img src="https://img.shields.io/github/forks/yourusername/quirzy?style=flat-square&color=green" alt="Forks"></a>
  <a href="#"><img src="https://img.shields.io/github/issues/yourusername/quirzy?style=flat-square&color=red" alt="Issues"></a>
  <a href="#"><img src="https://img.shields.io/github/last-commit/yourusername/quirzy?style=flat-square&color=purple" alt="Last Commit"></a>
</p>

<p align="center">
  <a href="#"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" alt="PRs Welcome"></a>
  <a href="#"><img src="https://img.shields.io/badge/Maintained-Yes-success?style=flat-square" alt="Maintained"></a>
  <a href="#"><img src="https://img.shields.io/badge/Made%20with-Love-ff69b4?style=flat-square" alt="Made with Love"></a>
</p>

---

## Quick Links

<p align="center">
  <a href="#overview">Overview</a> |
  <a href="#features">Features</a> |
  <a href="#demo">Demo</a> |
  <a href="#installation">Installation</a> |
  <a href="#usage">Usage</a> |
  <a href="#api-reference">API</a> |
  <a href="#contributing">Contributing</a> |
  <a href="#faq">FAQ</a>
</p>

---

## Table of Contents

<details>
<summary>Click to expand</summary>

- [Overview](#overview)
- [Features](#features)
- [Demo](#demo)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Building](#building)
- [Testing](#testing)
- [Deployment](#deployment)
- [Dependencies](#dependencies)
- [Performance](#performance)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Changelog](#changelog)
- [Authors](#authors)
- [Acknowledgements](#acknowledgements)
- [License](#license)

</details>

---

## Overview

<table>
<tr>
<td>

**Quirzy** is a cutting-edge mobile application that revolutionizes the way people learn. By harnessing the power of Google's Generative AI (Gemini), Quirzy transforms any topic into engaging quizzes and flashcards, making education accessible, personalized, and fun.

Whether you are a student preparing for exams, a professional upskilling, or a curious learner exploring new subjects, Quirzy adapts to your needs and learning pace.

### Why Quirzy?

- **Instant Content Generation**: No pre-made question banks. Generate fresh content on any topic instantly.
- **Adaptive Learning**: Choose difficulty levels that match your knowledge.
- **Gamified Experience**: Power-ups, streaks, and rewards keep you motivated.
- **Cross-Platform**: Seamless experience on both Android and iOS.
- **Offline Capable**: Access your saved quizzes and flashcards without internet.

</td>
</tr>
</table>

---

## Features

### AI-Powered Learning

<table>
<tr>
<td width="50%">

**Smart Quiz Generation**
- Generate quizzes on any topic using natural language
- AI creates relevant, educational questions
- Multiple choice format with intelligent distractors
- Explanations for correct answers

</td>
<td width="50%">

**Intelligent Flashcards**
- Auto-generate flashcard decks from topics
- Key concepts extracted and summarized
- Spaced repetition support
- Study progress tracking

</td>
</tr>
</table>

### Customization Options

| Option | Description | Values |
|--------|-------------|--------|
| **Difficulty** | Set the challenge level | Easy, Medium, Hard |
| **Question Count** | Number of questions per quiz | 5, 10, 15, 20 |
| **Timer** | Time limit per question | Enabled/Disabled |
| **Theme** | Visual appearance | Light, Dark, System |

### Power-Up System

<table>
<tr>
<td align="center" width="33%">
<img src="https://img.shields.io/badge/50%2F50-Remove%20Two%20Wrong%20Answers-orange?style=for-the-badge" alt="50/50">
<br><br>
Eliminates two incorrect options, making it easier to choose the right answer.
</td>
<td align="center" width="33%">
<img src="https://img.shields.io/badge/Freeze-Stop%20The%20Timer-blue?style=for-the-badge" alt="Freeze">
<br><br>
Pauses the countdown timer, giving you more time to think.
</td>
<td align="center" width="33%">
<img src="https://img.shields.io/badge/Shield-Second%20Chance-green?style=for-the-badge" alt="Shield">
<br><br>
Protects you from a wrong answer, allowing another attempt.
</td>
</tr>
</table>

### Gamification

- **Daily Streaks**: Maintain consecutive learning days for bonus rewards
- **XP System**: Earn experience points for completing quizzes
- **Achievements**: Unlock badges for milestones
- **Leaderboards**: Compare progress with other learners

### User Experience

| Feature | Description |
|---------|-------------|
| **Automatic Theme** | Seamlessly adapts to system preferences |
| **Voice Input** | Speak topics instead of typing |
| **Haptic Feedback** | Tactile responses for interactions |
| **Smooth Animations** | 60fps animations throughout |
| **Accessibility** | Screen reader compatible |

---

## Demo

### Screenshots

<p align="center">
  <i>Coming Soon</i>
</p>

### Video Walkthrough

<p align="center">
  <a href="#">
    <img src="https://img.shields.io/badge/Watch%20Demo-YouTube-red?style=for-the-badge&logo=youtube" alt="Watch Demo">
  </a>
</p>

---

## Architecture

Quirzy follows **Clean Architecture** principles with a feature-first modular structure.

```
                    ┌─────────────────────────────────────┐
                    │           Presentation              │
                    │   (Screens, Widgets, Controllers)   │
                    └─────────────────┬───────────────────┘
                                      │
                    ┌─────────────────▼───────────────────┐
                    │             Domain                  │
                    │    (Entities, Use Cases, Repos)     │
                    └─────────────────┬───────────────────┘
                                      │
                    ┌─────────────────▼───────────────────┐
                    │              Data                   │
                    │  (Repositories, Data Sources, API)  │
                    └─────────────────────────────────────┘
```

### Design Patterns

| Pattern | Implementation |
|---------|----------------|
| **Repository** | Abstracts data sources from business logic |
| **Provider** | State management with Riverpod |
| **Singleton** | Services like AdService, NotificationService |
| **Factory** | Quiz and Flashcard generation |
| **Observer** | Reactive UI updates |

### State Management

<p align="center">
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/Riverpod-Provider%20Framework-purple?style=for-the-badge" alt="Riverpod"></a>
</p>

Quirzy uses **Riverpod** for state management, providing:

- Compile-time safety and error catching
- Dependency injection and lazy loading
- Easy testing with provider overrides
- Automatic disposal of providers

---

## Tech Stack

### Core Technologies

<table>
<tr>
<td align="center" width="25%">
<a href="https://flutter.dev">
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
</a>
<br>Cross-platform Framework
</td>
<td align="center" width="25%">
<a href="https://dart.dev">
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</a>
<br>Programming Language
</td>
<td align="center" width="25%">
<a href="https://firebase.google.com">
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
</a>
<br>Backend Services
</td>
<td align="center" width="25%">
<a href="https://ai.google.dev">
<img src="https://img.shields.io/badge/Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini">
</a>
<br>AI Generation
</td>
</tr>
</table>

### Backend and Services

| Service | Purpose | Documentation |
|---------|---------|---------------|
| <a href="https://firebase.google.com/docs/auth"><img src="https://img.shields.io/badge/Firebase%20Auth-Authentication-FFCA28?logo=firebase" alt="Auth"></a> | User authentication | [Docs](https://firebase.google.com/docs/auth) |
| <a href="https://firebase.google.com/docs/cloud-messaging"><img src="https://img.shields.io/badge/FCM-Push%20Notifications-FFCA28?logo=firebase" alt="FCM"></a> | Push notifications | [Docs](https://firebase.google.com/docs/cloud-messaging) |
| <a href="https://appwrite.io"><img src="https://img.shields.io/badge/Appwrite-Backend-F02E65?logo=appwrite" alt="Appwrite"></a> | Backend as a Service | [Docs](https://appwrite.io/docs) |
| <a href="https://ai.google.dev/docs"><img src="https://img.shields.io/badge/Gemini%20API-AI%20Generation-8E75B2?logo=google" alt="Gemini"></a> | Content generation | [Docs](https://ai.google.dev/docs) |

### Storage Solutions

| Technology | Purpose | Documentation |
|------------|---------|---------------|
| <a href="https://docs.hivedb.dev"><img src="https://img.shields.io/badge/Hive-Local%20Database-orange" alt="Hive"></a> | NoSQL local storage | [Docs](https://docs.hivedb.dev) |
| <a href="https://pub.dev/packages/shared_preferences"><img src="https://img.shields.io/badge/SharedPreferences-Key%20Value-blue" alt="SharedPrefs"></a> | Simple preferences | [Docs](https://pub.dev/packages/shared_preferences) |
| <a href="https://pub.dev/packages/flutter_secure_storage"><img src="https://img.shields.io/badge/Secure%20Storage-Encrypted-green" alt="Secure"></a> | Sensitive data | [Docs](https://pub.dev/packages/flutter_secure_storage) |

### UI and Animation Libraries

| Library | Purpose | Link |
|---------|---------|------|
| `google_fonts` | Typography | [pub.dev](https://pub.dev/packages/google_fonts) |
| `flutter_animate` | Declarative animations | [pub.dev](https://pub.dev/packages/flutter_animate) |
| `avatar_glow` | Glowing effects | [pub.dev](https://pub.dev/packages/avatar_glow) |
| `confetti` | Celebration effects | [pub.dev](https://pub.dev/packages/confetti) |
| `lottie` | Vector animations | [pub.dev](https://pub.dev/packages/lottie) |
| `fl_chart` | Charts and graphs | [pub.dev](https://pub.dev/packages/fl_chart) |

---

## Project Structure

```
quirzy/
├── android/                      # Android platform files
│   ├── app/
│   │   ├── build.gradle.kts      # App build configuration
│   │   ├── google-services.json  # Firebase config (gitignored)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/           # Native Kotlin code
│   └── build.gradle.kts          # Project build configuration
│
├── ios/                          # iOS platform files
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── GoogleService-Info.plist  # Firebase config (gitignored)
│   └── Podfile
│
├── lib/                          # Main Dart source code
│   ├── main.dart                 # Application entry point
│   ├── app.dart                  # Root MaterialApp widget
│   │
│   ├── config/                   # App configuration
│   │   └── init.dart             # Initialization logic
│   │
│   ├── core/                     # Shared core modules
│   │   ├── constants/            # App-wide constants
│   │   │   └── notification_messages.dart
│   │   ├── services/             # Core services
│   │   │   ├── ad_service.dart
│   │   │   ├── local_notification_service.dart
│   │   │   └── notification_service.dart
│   │   ├── theme/                # Theme definitions
│   │   │   └── app_theme.dart
│   │   └── widgets/              # Reusable widgets
│   │       ├── app/
│   │       └── loading/
│   │
│   ├── features/                 # Feature modules
│   │   ├── auth/                 # Authentication
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── flashcards/           # Flashcard feature
│   │   │   ├── screens/
│   │   │   └── services/
│   │   │
│   │   ├── history/              # Quiz history
│   │   │   └── screens/
│   │   │
│   │   ├── home/                 # Home screen
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   │
│   │   ├── profile/              # User profile
│   │   │   └── presentation/
│   │   │
│   │   ├── quiz/                 # Quiz feature
│   │   │   ├── screens/
│   │   │   └── services/
│   │   │
│   │   └── settings/             # App settings
│   │       ├── presentation/
│   │       └── providers/
│   │
│   ├── providers/                # Global providers
│   │   └── user_stats_provider.dart
│   │
│   └── routes/                   # Navigation
│       ├── app_routes.dart
│       └── router.dart
│
├── assets/                       # Static assets
│   ├── icon/                     # App icons
│   └── splash/                   # Splash screen
│
├── test/                         # Test files
│
├── pubspec.yaml                  # Dependencies
├── analysis_options.yaml         # Linter rules
└── README.md                     # This file
```

---

## Getting Started

### Prerequisites

<table>
<tr>
<td>

**Required Software**

| Software | Version | Download |
|----------|---------|----------|
| Flutter SDK | 3.8.1+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| Dart SDK | 3.8.1+ | Included with Flutter |
| Android Studio | Latest | [developer.android.com](https://developer.android.com/studio) |
| VS Code | Latest | [code.visualstudio.com](https://code.visualstudio.com) |
| JDK | 17+ | [adoptium.net](https://adoptium.net) |
| Xcode | 14+ | Mac App Store (macOS only) |

</td>
</tr>
</table>

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/quirzy.git

# Navigate to project directory
cd quirzy

# Install dependencies
flutter pub get

# Run code generation (if needed)
dart run build_runner build --delete-conflicting-outputs

# Verify setup
flutter doctor

# Run the app
flutter run
```

### Configuration

#### 1. Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### 2. Environment Variables

Create `.env` file in project root:

```env
# AI Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Appwrite Configuration
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_DATABASE_ID=your_database_id
APPWRITE_QUIZ_COLLECTION_ID=your_collection_id

# AdMob Configuration (Optional)
ADMOB_APP_ID=your_admob_app_id
ADMOB_REWARDED_ID=your_rewarded_ad_id
```

#### 3. Signing Configuration

Create `android/key.properties`:

```properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

---

## Usage

### Generating a Quiz

```dart
// Example: Generate a quiz programmatically
final quizService = QuizService();
final quiz = await quizService.generateQuiz(
  'Machine Learning Basics',
  questionCount: 10,
  difficulty: 'medium',
);
```

### Generating Flashcards

```dart
// Example: Generate flashcards
final flashcardService = FlashcardService();
final cards = await flashcardService.generateFlashcards(
  'Biology Cell Structure',
  cardCount: 15,
);
```

---

## API Reference

### Quiz Service

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `generateQuiz()` | topic, count, difficulty | `Quiz` | Generate AI quiz |
| `getQuizHistory()` | userId | `List<Quiz>` | Get past quizzes |
| `saveQuizResult()` | quiz, score | `void` | Save quiz result |

### Flashcard Service

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `generateFlashcards()` | topic, count | `FlashcardSet` | Generate cards |
| `getFlashcardSets()` | forceRefresh | `List<FlashcardSet>` | Get all sets |
| `deleteFlashcardSet()` | setId | `void` | Delete a set |

---

## Building

### Development Builds

```bash
# Debug APK
flutter build apk --debug

# Debug iOS
flutter build ios --debug --no-codesign
```

### Production Builds

```bash
# Release APK
flutter build apk --release

# Release App Bundle (recommended for Play Store)
flutter build appbundle --release

# Release with obfuscation
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# Release iOS
flutter build ios --release
```

### Build Outputs

| Build | Location | Size |
|-------|----------|------|
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` | ~80MB |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` | ~25MB |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` | ~60MB |

---

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## Deployment

### Google Play Store

1. Build release app bundle
2. Upload to [Play Console](https://play.google.com/console)
3. Complete store listing
4. Submit for review

### Apple App Store

1. Build release IPA
2. Upload via Xcode or Transporter
3. Complete App Store Connect listing
4. Submit for review

---

## Dependencies

<details>
<summary>View Full Dependency List</summary>

### Production Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^3.0.3
  riverpod_annotation: ^3.0.3
  
  # Navigation
  go_router: ^16.3.0
  
  # UI/UX
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.2
  avatar_glow: ^3.0.1
  confetti: ^0.8.0
  lottie: ^3.1.0
  fl_chart: ^0.69.2
  showcaseview: ^4.0.1
  
  # Backend
  firebase_core: ^4.2.1
  firebase_auth: ^6.1.2
  firebase_messaging: ^16.0.4
  appwrite: ^15.2.4
  google_generative_ai: ^0.4.7
  
  # Storage
  hive_flutter: ^1.1.0
  shared_preferences: ^2.5.3
  flutter_secure_storage: ^9.2.4
  
  # Monetization
  google_mobile_ads: ^6.0.0
  
  # Utilities
  speech_to_text: ^7.0.0
  flutter_tts: ^4.2.3
  share_plus: ^10.0.3
  url_launcher: ^6.2.5
  connectivity_plus: ^6.0.5
  http: ^1.2.0
  intl: ^0.20.2
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  riverpod_generator: ^3.0.3
  build_runner: ^2.7.1
  flutter_launcher_icons: ^0.14.1
  flutter_native_splash: ^2.4.2
```

</details>

---

## Performance

### Optimization Techniques

- **Lazy Loading**: Providers loaded on demand
- **Image Caching**: Efficient asset management
- **Code Splitting**: Modular feature loading
- **Tree Shaking**: Dead code elimination
- **Obfuscation**: Smaller and secure builds

### Benchmarks

| Metric | Value |
|--------|-------|
| Cold Start | < 2s |
| Hot Reload | < 1s |
| Quiz Generation | 2-5s |
| Memory Usage | < 150MB |

---

## Security

- **Secure Storage**: Sensitive data encrypted with platform keychain
- **API Keys**: Stored in secure environment configuration
- **Code Obfuscation**: Release builds are obfuscated
- **Certificate Pinning**: Enabled for API calls
- **No Logging**: Production builds exclude debug logs

---

## Troubleshooting

<details>
<summary>Common Issues</summary>

### Build Failures

**Issue**: Gradle build fails
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

**Issue**: iOS build fails
```bash
# Solution: Update pods
cd ios && pod install --repo-update && cd ..
```

### Runtime Issues

**Issue**: Firebase initialization error
- Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is present

**Issue**: API key not working
- Verify `.env` file exists and contains valid keys
- Check Gemini API quota

</details>

---

## FAQ

<details>
<summary>Frequently Asked Questions</summary>

**Q: Is Quirzy free to use?**
A: Yes, with ad-supported content generation after the free limit.

**Q: Does it work offline?**
A: Previously generated quizzes and flashcards are available offline.

**Q: What topics can I generate quizzes on?**
A: Any topic! The AI can generate educational content on virtually any subject.

**Q: How is my data stored?**
A: Locally on device with optional cloud backup via Appwrite.

</details>

---

## Roadmap

- [ ] Multiplayer quiz mode
- [ ] Social sharing
- [ ] Custom quiz creation
- [ ] Export to PDF
- [ ] Web version
- [ ] Desktop apps

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2026-01-01 | Ad integration, system theme, UI improvements, flashcard ads |
| 1.0.0 | 2025-12-XX | Initial release |

See [CHANGELOG.md](CHANGELOG.md) for detailed history.

---

## Contributing

<a href="#"><img src="https://img.shields.io/badge/Contributions-Welcome-brightgreen?style=for-the-badge" alt="Contributions Welcome"></a>

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Authors

<table>
<tr>
<td align="center">
<a href="https://github.com/yourusername">
<img src="https://img.shields.io/badge/Developer-Hannu%20Pratap-blue?style=for-the-badge" alt="Author">
</a>
</td>
</tr>
</table>

---

## Acknowledgements

- [Flutter Team](https://flutter.dev) - Cross-platform framework
- [Google AI](https://ai.google.dev) - Gemini AI API
- [Firebase](https://firebase.google.com) - Backend services
- [Riverpod](https://riverpod.dev) - State management
- [pub.dev](https://pub.dev) - Package ecosystem

---

## Support

<p align="center">
  <a href="mailto:support@quirzy.app"><img src="https://img.shields.io/badge/Email-Support-red?style=for-the-badge&logo=gmail" alt="Email"></a>
  <a href="#"><img src="https://img.shields.io/badge/Discord-Community-5865F2?style=for-the-badge&logo=discord" alt="Discord"></a>
  <a href="#"><img src="https://img.shields.io/badge/Twitter-Follow-1DA1F2?style=for-the-badge&logo=twitter" alt="Twitter"></a>
</p>

---

## License

This project is proprietary software. All rights reserved.

---

<p align="center">
  <img src="https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Built with Flutter">
  <img src="https://img.shields.io/badge/Powered%20by-Gemini%20AI-8E75B2?style=for-the-badge&logo=google" alt="Powered by Gemini">
</p>

<p align="center">
  Made with dedication in India
</p>

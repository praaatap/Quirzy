# 🚀 Quick Reference Guide - Quirzy Codebase

> **New to the project?** Start here! This guide helps you navigate the codebase quickly.

## 📁 Current Folder Structure

```
lib/
├── 📂 features/          ⭐ MAIN CODE - Start here!
├── 📂 shared/            🔧 Common widgets & utilities
├── 📂 core/              ⚙️ App configuration
├── 📂 models/            📊 Data models (being migrated)
├── 📂 providers/         🔄 State management (being migrated)
├── 📂 service/           🌐 Services (being migrated)
├── 📂 theme/             🎨 Theming (being migrated to core/)
├── 📂 utils/             🛠️ Utilities (being migrated to shared/)
├── 📂 _old_structure/    ⛔ DO NOT USE - Legacy code
└── 📄 main.dart          🚪 App entry point
```

## 🎯 Where to Find Things

### Looking for Screens?

| What you need | Where to look |
|---------------|---------------|
| Login/Signup screens | `lib/features/auth/screens/` |
| Quiz screens | `lib/features/quiz/screens/` |
| Home/Dashboard | `lib/features/home/screens/` |
| Profile screen | `lib/features/profile/screens/` |
| History screens | `lib/features/history/screens/` |
| Flashcard screens | `lib/features/flashcards/screens/` |
| Settings screen | `lib/features/settings/screens/` |

### Looking for Widgets?

| Widget type | Location |
|-------------|----------|
| Buttons | `lib/shared/widgets/buttons/` |
| Input fields | `lib/shared/widgets/inputs/` |
| Loading indicators | `lib/shared/widgets/loading/` |
| Connectivity widgets | `lib/shared/widgets/connectivity/` |
| Feature-specific widgets | `lib/features/[feature]/widgets/` |

### Looking for Business Logic?

| Logic type | Location |
|------------|----------|
| Authentication | `lib/features/auth/providers/` |
| Quiz logic | `lib/features/quiz/` |
| Profile logic | `lib/features/profile/services/` |
| Flashcard logic | `lib/features/flashcards/services/` |

### Looking for Data Models?

| Model type | Current location | Future location |
|------------|------------------|-----------------|
| Shared models | `lib/models/` | `lib/shared/models/` |
| Feature models | `lib/features/[feature]/` | Same (good!) |

## ✍️ Adding New Code

### Adding a New Screen

**Example:** Adding a "Leaderboard" screen

```dart
// 1. Create the screen file
lib/features/leaderboard/
  └── screens/
      └── leaderboard_screen.dart

// 2. Add providers if needed
lib/features/leaderboard/
  └── providers/
      └── leaderboard_provider.dart

// 3. Add services if needed
lib/features/leaderboard/
  └── services/
      └── leaderboard_service.dart
```

### Adding a New Widget

**Shared Widget (used in multiple features):**
```dart
lib/shared/widgets/cards/
  └── custom_card.dart
```

**Feature-Specific Widget:**
```dart
lib/features/quiz/widgets/
  └── quiz_timer.dart
```

### Adding a New Service

**Shared Service:**
```dart
lib/shared/services/
  └── notification_service.dart
```

**Feature Service:**
```dart
lib/features/quiz/services/
  └── quiz_service.dart  // Already exists!
```

## 🔍 Common Tasks

### 1. Modifying the Quiz Question UI
```
📁 lib/features/quiz/screens/quiz_question_screen.dart
```

### 2. Changing Button Styles
```
📁 lib/shared/widgets/buttons/
```

### 3. Adding Authentication Logic
```
📁 lib/features/auth/providers/auth_provider.dart
📁 lib/features/auth/screens/
```

### 4. Updating Theme Colors
```
📁 lib/theme/ (will move to lib/core/theme/)
```

### 5. Adding API Calls
```
📁 lib/shared/services/ (for shared APIs)
📁 lib/features/[feature]/services/ (for feature-specific)
```

## 🚨 Important Rules

### ✅ DO:
- ✅ Use code from `lib/features/`
- ✅ Use code from `lib/shared/`
- ✅ Use code from `lib/core/`
- ✅ Add new features in `lib/features/[feature_name]/`
- ✅ Follow the existing folder structure

### ❌ DON'T:
- ❌ Use code from `lib/_old_structure/`
- ❌ Add new code to `lib/_old_structure/`
- ❌ Import from legacy folders
- ❌ Mix business logic with UI code
- ❌ Create God classes/widgets

## 📚 Feature Structure Template

When creating a new feature, use this structure:

```
lib/features/[feature_name]/
├── screens/              # UI screens
│   └── [feature]_screen.dart
├── widgets/              # Feature-specific widgets (optional)
│   └── [feature]_widget.dart
├── providers/            # State management (optional)
│   └── [feature]_provider.dart
├── services/             # Business logic & API calls (optional)
│   └── [feature]_service.dart
├── models/               # Feature models (optional)
│   └── [feature]_model.dart
└── [feature].dart        # Feature exports
```

## 🔗 Related Documents

- 📖 [Full Folder Structure Documentation](FOLDER_STRUCTURE.md)
- 📖 [Project Structure Overview](../PROJECT_STRUCTURE.md)
- 📖 [Contributing Guidelines](CONTRIBUTING.md)
- 📖 [README](README.md)

## 💡 Pro Tips

1. **Finding a file?** Use VS Code's `Ctrl+P` (Cmd+P on Mac) and start typing
2. **Finding code?** Use `Ctrl+Shift+F` for global search
3. **Not sure where to add code?** Check existing similar features
4. **Imports broken?** Check if code moved to `_old_structure/`

## 🆘 Need Help?

- Check `FOLDER_STRUCTURE.md` for detailed migration info
- Look at existing features for examples
- Open an issue on GitHub
- Contact the maintainers

---

**Quick Start:**
1. Clone the repo
2. Run `flutter pub get`
3. Check `lib/features/` for main code
4. Check `lib/shared/` for reusable components
5. Start coding! 🚀

**Last Updated**: December 19, 2025

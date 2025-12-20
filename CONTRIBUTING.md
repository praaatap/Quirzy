# Contributing to Quirzy

Thank you for your interest in contributing to Quirzy! 🎉

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
│
├── core/                     # Core infrastructure
│   ├── config/               # App & API configuration
│   ├── storage/              # Hive database & caching
│   └── theme/                # App theming
│
├── features/                 # Feature modules (main code lives here)
│   ├── auth/                 # Authentication (login, signup, welcome)
│   ├── home/                 # Home screen & main navigation
│   ├── quiz/                 # Quiz generation & taking
│   ├── history/              # Quiz history & stats
│   ├── profile/              # User profile
│   └── settings/             # App settings
│
└── shared/                   # Shared/reusable components
    ├── widgets/              # Reusable UI widgets
    ├── services/             # Shared services (ads, notifications)
    └── utils/                # Constants & utilities
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8+)
- Dart SDK (3.8+)
- Android Studio or VS Code
- Git

### Setup

1. **Fork & Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/quirzy.git
   cd quirzy
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## 🛠 How to Contribute

### 1. Find an Issue
- Check [Issues](../../issues) for open tasks
- Look for `good first issue` label for beginner-friendly tasks
- Look for `help wanted` label for priority items

### 2. Create a Branch
```bash
git checkout -b feature/your-feature-name
# OR
git checkout -b fix/bug-description
```

### 3. Make Changes
- Follow the existing code style
- Add comments for complex logic
- Test your changes thoroughly

### 4. Commit
Use clear commit messages:
```bash
git commit -m "feat: add dark mode toggle"
git commit -m "fix: resolve quiz loading issue"
git commit -m "docs: update contributing guide"
```

Prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style/formatting
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance

### 5. Push & Create PR
```bash
git push origin feature/your-feature-name
```
Then create a Pull Request on GitHub.

## 📝 Code Guidelines

### File Naming
- Use `snake_case` for file names
- Example: `home_screen.dart`, `quiz_service.dart`

### Class Naming
- Use `PascalCase` for classes
- Example: `HomeScreen`, `QuizService`

### Folder Structure
Each feature should have:
```
feature_name/
├── feature_name.dart    # Barrel export file
├── screens/             # UI screens
├── providers/           # State management (Riverpod)
├── services/            # API/business logic
└── widgets/             # Feature-specific widgets
```

### State Management
- We use **Riverpod** for state management
- Create providers in the `providers/` folder
- Use `Notifier` pattern (not legacy `StateNotifier`)

### Imports
Use package imports, not relative:
```dart
// ✅ Good
import 'package:quirzy/features/home/home.dart';

// ❌ Bad
import '../../../features/home/home.dart';
```

## 🐛 Reporting Bugs

1. Check if the bug is already reported
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if UI bug)
   - Device/OS info

## 💡 Suggesting Features

1. Check existing feature requests
2. Create an issue with:
   - Clear description
   - Use case / why it's needed
   - Mockups (optional but helpful)

## ❓ Questions?

Feel free to open an issue with the `question` label.

---

Happy coding! 🚀

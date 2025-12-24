# Quirzy - AI-Powered Quiz Generation App

<p align="center">
  <img src="assets/icon.png" width="120" alt="Quirzy Logo">
</p>

<p align="center">
  <strong>Transform any content into interactive quizzes and flashcards using AI.</strong>
</p>

---

## 🚀 Features

### Core Features
- **AI Quiz Generation** - Generate quizzes from PDFs, images, and text
- **Smart Flashcards** - Create and study flashcards with spaced repetition
- **Quiz History** - Track progress and review past performance
- **Offline Support** - Study anywhere with intelligent caching
- **Push Notifications** - Study reminders and updates
- **Dark/Light Theme** - Beautiful Material 3 design

---

## 🏗️ Architecture

Clean Architecture with feature-first organization:

```
lib/
├── core/                    # Core utilities
│   ├── config/              # Configuration
│   ├── platform/            # Platform-adaptive utilities
│   ├── storage/             # Hive + Isolate caching
│   ├── theme/               # Material 3 theming
│   └── utils/               # Isolate compute
│
├── features/                # Feature modules
│   ├── auth/                # Authentication
│   ├── quiz/                # Quiz generation
│   ├── flashcards/          # Flashcard study
│   ├── history/             # Performance tracking
│   ├── profile/             # User profile
│   ├── settings/            # App settings
│   └── home/                # Navigation
│
├── providers/               # Global providers
├── service/                 # Shared services
├── shared/                  # Reusable widgets
└── main.dart                # Entry (~85 lines)
```

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.x |
| **State** | Riverpod |
| **Storage** | Hive + Isolates |
| **Backend** | Firebase + REST API |
| **AI** | Groq AI |
| **Auth** | Firebase Auth + JWT |

---

## ⚡ Performance

- **Isolate-based processing** for heavy computations
- **Multi-layer caching** (Memory + Hive)
- **Parallel initialization** for fast startup
- **Smart cache invalidation**

---

## 🚀 Getting Started

```bash
git clone https://github.com/yourusername/quirzy.git
cd quirzy
flutter pub get
flutter run
```

---

## 📄 License

MIT License

---

<p align="center">Made with ❤️ using Flutter</p>

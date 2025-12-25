# Quirzy - AI-Powered Quiz Generation App

<p align="center">
  <img src="assets/icon.png" width="120" alt="Quirzy Logo">
</p>

<p align="center">
  <strong>Transform any content into interactive quizzes and flashcards using AI.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/License-Proprietary-red.svg" alt="License">
  <img src="https://img.shields.io/badge/Status-Showcase%20Only-orange.svg" alt="Status">
  <img src="https://img.shields.io/badge/Copying-Prohibited-critical.svg" alt="No Copying">
</p>

---

> ⚠️ **PROPRIETARY SOFTWARE - READ BEFORE VIEWING**
>
> This repository is **PUBLIC FOR SHOWCASE PURPOSES ONLY**. All rights are reserved.
>
> ❌ **YOU MAY NOT:** Copy, modify, distribute, or use this code in any project.
>
> ✅ **YOU MAY:** View for portfolio evaluation, educational reference, and code review.
>
> See [LICENSE](./LICENSE) for full terms. Unauthorized use may result in legal action.

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

**PROPRIETARY LICENSE - ALL RIGHTS RESERVED**

This software is proprietary and confidential. It is made publicly available for **viewing purposes only** as a portfolio showcase.

| ✅ Permitted | ❌ Prohibited |
|-------------|--------------|
| Viewing source code | Copying any code |
| Portfolio evaluation | Using in your projects |
| Educational reference | Modifying or distributing |
| Code review | Commercial use |

See the [LICENSE](./LICENSE) file for complete terms.

**© 2025 Quirzy - Unauthorized reproduction is prohibited by law.**

---

<p align="center">Made with ❤️ using Flutter</p>
<p align="center"><em>This project is public for showcase only. All rights reserved.</em></p>

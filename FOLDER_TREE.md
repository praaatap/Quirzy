# Quirzy Folder Structure Visual Guide

## 🗂️ Complete Directory Tree

```
quirzy/lib/
│
├── 📂 features/                          ⭐ MAIN APPLICATION CODE
│   │
│   ├── 🔐 auth/                          Authentication & User Access
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── success_screen.dart
│   │   │   └── welcome_screen.dart
│   │   └── auth.dart
│   │
│   ├── 📝 quiz/                          Quiz Taking & Generation
│   │   ├── screens/
│   │   │   ├── quiz_question_screen.dart
│   │   │   ├── quiz_completed_screen.dart
│   │   │   └── start_quiz_screen.dart
│   │   ├── services/
│   │   │   └── quiz_service.dart
│   │   └── quiz.dart
│   │
│   ├── 🎴 flashcards/                    Flashcard Study Mode
│   │   ├── screens/
│   │   │   ├── flashcards_screen.dart
│   │   │   └── flashcard_study_screen.dart
│   │   ├── services/
│   │   │   ├── flashcard_service.dart
│   │   │   └── flashcard_cache_service.dart
│   │   └── flashcards.dart
│   │
│   ├── 📊 history/                       Quiz History & Stats
│   │   ├── providers/
│   │   │   └── quiz_history_provider.dart
│   │   ├── screens/
│   │   │   ├── history_screen.dart
│   │   │   └── quiz_stats_screen.dart
│   │   └── history.dart
│   │
│   ├── 🏠 home/                          Main Dashboard
│   │   ├── screens/
│   │   │   ├── home_screen.dart
│   │   │   └── main_screen.dart
│   │   └── home.dart
│   │
│   ├── 👤 profile/                       User Profile
│   │   ├── screens/
│   │   │   └── profile_screen.dart
│   │   ├── services/
│   │   │   └── profile_service.dart
│   │   └── profile.dart
│   │
│   ├── ⚙️ settings/                      App Settings
│   │   ├── screens/
│   │   │   └── settings_screen.dart
│   │   └── settings.dart
│   │
│   └── features.dart                     Feature exports
│
├── 🔧 shared/                             SHARED COMPONENTS
│   │
│   ├── widgets/                          Reusable UI Components
│   │   ├── buttons/
│   │   │   └── custom_button.dart
│   │   ├── inputs/
│   │   │   └── custom_text_field.dart
│   │   ├── loading/
│   │   │   ├── loading_screen.dart
│   │   │   ├── loading_overlay.dart
│   │   │   └── shimmer_loading.dart
│   │   ├── connectivity/
│   │   │   └── internet_connection_wrapper.dart
│   │   └── widgets.dart
│   │
│   ├── services/                         Shared Services
│   │   ├── ad_service.dart              AdMob integration
│   │   ├── api_service.dart             Backend API
│   │   ├── notification_service.dart    Push notifications
│   │   └── user_data_service.dart       User data management
│   │
│   ├── utils/                            Utility Functions
│   │   ├── constants.dart
│   │   └── helpers.dart
│   │
│   └── shared.dart                       Shared exports
│
├── ⚙️ core/                               APP CORE
│   ├── constants/
│   ├── config/
│   ├── routes/
│   ├── storage/
│   │   └── hive_cache_service.dart
│   └── theme/
│
├── 📊 models/                             DATA MODELS (TO BE MIGRATED)
│   ├── quiz_model.dart
│   ├── user_model.dart
│   └── ...
│
├── 🔄 providers/                          STATE MANAGEMENT (TO BE MIGRATED)
│   ├── auth_provider.dart
│   ├── quiz_provider.dart
│   └── ...
│
├── 🌐 service/                            SERVICES (TO BE MIGRATED)
│   ├── api_service.dart
│   ├── ad_service.dart
│   ├── notification_service.dart
│   └── ...
│
├── 🎨 theme/                              THEMING (TO BE MIGRATED TO CORE)
│   └── app_theme.dart
│
├── 🛠️ utils/                              UTILITIES (TO BE MIGRATED TO SHARED)
│   └── helpers.dart
│
├── ⛔ _old_structure/                     LEGACY CODE (DO NOT USE)
│   ├── screen/                           Old screens folder
│   │   ├── quizPage/
│   │   ├── introduction/
│   │   ├── mainPage/
│   │   ├── profile/
│   │   ├── history/
│   │   ├── settings/
│   │   └── ...
│   ├── widgets/                          Old widgets folder
│   │   ├── Button.dart
│   │   ├── textfiled.dart
│   │   └── ...
│   └── README.md                         ⚠️ Warning about legacy code
│
└── 📄 main.dart                           🚪 APPLICATION ENTRY POINT
```

## 🎨 Legend

| Icon | Meaning |
|------|---------|
| ⭐ | Primary code location - start here |
| 🔐 | Authentication related |
| 📝 | Quiz functionality |
| 🎴 | Flashcards feature |
| 📊 | Data & statistics |
| 🏠 | Home/Dashboard |
| 👤 | User profile |
| ⚙️ | Configuration & settings |
| 🔧 | Shared utilities |
| 🌐 | Backend services |
| 🔄 | State management |
| 🎨 | Theming |
| 🛠️ | Tools & helpers |
| ⛔ | Do not use |
| 🚪 | Entry point |

## 📐 Folder Size & Complexity

| Folder | Estimated Files | Complexity | Priority |
|--------|----------------|------------|----------|
| `features/` | 29 files | ⭐⭐⭐⭐⭐ | HIGH - Main code |
| `shared/` | 14 files | ⭐⭐⭐ | MEDIUM - Utilities |
| `core/` | 5 files | ⭐⭐ | LOW - Setup |
| `_old_structure/` | 23 files | ⛔ | N/A - Don't use |

## 🔍 Quick Find Reference

### Need a specific file?

| What you're looking for | Path |
|------------------------|------|
| Quiz question UI | `features/quiz/screens/quiz_question_screen.dart` |
| Login screen | `features/auth/screens/login_screen.dart` |
| Profile page | `features/profile/screens/profile_screen.dart` |
| Home dashboard | `features/home/screens/home_screen.dart` |
| Settings | `features/settings/screens/settings_screen.dart` |
| Custom button | `shared/widgets/buttons/custom_button.dart` |
| Loading indicator | `shared/widgets/loading/` |
| API service | `shared/services/api_service.dart` |
| AdMob service | `shared/services/ad_service.dart` |

## 🚀 Migration Status

| Component | Old Location | New Location | Status |
|-----------|-------------|--------------|--------|
| Screens | `screen/` | `features/*/screens/` | ✅ Migrated |
| Widgets | `widgets/` | `shared/widgets/` | ✅ Migrated |
| Models | `models/` | `features/*/data/models/` | 🔄 In Progress |
| Providers | `providers/` | `features/*/providers/` | 🔄 In Progress |
| Services | `service/` | `shared/services/` | 🔄 In Progress |
| Theme | `theme/` | `core/theme/` | ⏳ Pending |
| Utils | `utils/` | `shared/utils/` | ⏳ Pending |

## 📝 Notes

1. **Active Development**: Focus on `features/` and `shared/`
2. **Legacy Code**: Anything in `_old_structure/` is deprecated
3. **Migration**: Root-level folders (`models/`, `providers/`, etc.) are being migrated
4. **Clean Architecture**: New features should follow the three-layer pattern:
   - `data/` - Data sources, models, repositories
   - `domain/` - Business logic, use cases
   - `presentation/` - UI, screens, widgets, state

## 🎯 Best Practices

✅ **Follow this structure for new features:**
```
features/new_feature/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   └── usecases/
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
```

## 📚 Related Documentation

- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Quick navigation guide
- [FOLDER_STRUCTURE.md](FOLDER_STRUCTURE.md) - Detailed structure docs
- [README.md](README.md) - Project README

---

**Last Updated**: December 19, 2025  
**Version**: 2.0 (Post-Reorganization)

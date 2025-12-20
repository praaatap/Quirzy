# Quirzy Library Structure Reorganization

## 📊 Current Issues Identified

### Duplication Problems:
1. **`lib/screen/`** vs **`lib/features/`** - Same screens in both places
2. **`lib/widgets/`** vs **`lib/shared/widgets/`** - Duplicate widget folders  
3. **`lib/shared/`** contains its own nested structure (providers, screens, services, utils, widgets)

## ✅ New Proposed Structure

```
lib/
├── core/                      # Core app functionality
│   ├── constants/            # App-wide constants
│   ├── config/               # App configuration
│   ├── routes/               # Navigation routes
│   └── theme/                # Theme configuration
│
├── features/                  # Feature modules (MAIN STRUCTURE)
│   ├── auth/                 # Authentication
│   │   ├── data/            # Data layer (models, repositories)
│   │   ├── domain/          # Business logic (use cases)
│   │   ├── presentation/    # UI layer (screens, widgets, providers)
│   │   └── auth.dart        # Feature export file
│   │
│   ├── quiz/                 # Quiz feature
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── quiz.dart
│   │
│   ├── flashcards/           # Flashcards feature
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── flashcards.dart
│   │
│   ├── profile/              # User profile
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── profile.dart
│   │
│   ├── history/              # Quiz history
│   │   ├── data/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── history.dart
│   │
│   ├── settings/             # App settings
│   │   ├── presentation/
│   │   └── settings.dart
│   │
│   └── home/                 # Home/Dashboard
│       ├── presentation/
│       └── home.dart
│
├── shared/                    # Shared across features
│   ├── widgets/              # Reusable widgets only
│   │   ├── buttons/
│   │   ├── inputs/
│   │   ├── loading/
│   │   ├── connectivity/
│   │   └── widgets.dart     # Export file
│   │
│   ├── utils/                # Helper functions
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── utils.dart       # Export file
│   │
│   ├── models/               # Shared data models
│   ├── services/             # Shared services
│   └── extensions/           # Dart extensions
│
├── _old_structure/            # OLD CODE (to be deleted)
│   ├── screen/               # OLD: Legacy screens
│   └── widgets/              # OLD: Legacy widgets
│
└── main.dart                  # App entry point
```

## 🔄 Migration Plan

### Phase 1: Move Legacy Code (DONE ✓)
- [x] Moved `lib/screen/` → `lib/_old_structure/screen/`
- [x] Moved `lib/widgets/` → `lib/_old_structure/widgets/`

### Phase 2: Consolidate Shared Resources
- [ ] Move `lib/shared/widgets/` → `lib/shared/widgets/` (keep as is, it's good)
- [ ] Move `lib/shared/utils/` → `lib/shared/utils/` (keep as is)
- [ ] Move `lib/shared/services/` → `lib/shared/services/` (keep as is)
- [ ] Remove `lib/shared/providers/` → Merge into feature-specific providers
- [ ] Remove `lib/shared/screens/` → Move to appropriate features

### Phase 3: Reorganize Features (Clean Architecture)
Each feature should follow clean architecture with:
- **data/** - Models, data sources, repositories
- **domain/** - Business logic, use cases, entities
- **presentation/** - Screens, widgets, state management

### Phase 4: Clean Up Root-Level Folders
- [ ] Merge `lib/models/` → Move to feature-specific `data/models/`
- [ ] Merge `lib/providers/` → Move to feature-specific `presentation/providers/`
- [ ] Merge `lib/service/` → Move to `lib/shared/services/` or feature-specific
- [ ] Keep `lib/utils/` → Merge with `lib/shared/utils/`
- [ ] Remove `lib/theme/` → Move to `lib/core/theme/`

## 📁 Folder Purposes

### `lib/features/` 
Main application code organized by feature. Each feature is self-contained.

**Example Feature Structure:**
```
features/quiz/
├── data/
│   ├── models/              # Data transfer objects
│   ├── datasources/         # API, local DB
│   └── repositories/        # Repository implementations
├── domain/
│   ├── entities/            # Business objects
│   ├── usecases/            # Business logic
│   └── repositories/        # Repository interfaces
├── presentation/
│   ├── screens/             # UI screens
│   ├── widgets/             # Feature-specific widgets
│   ├── providers/           # State management
│   └── quiz_screen.dart
└── quiz.dart                # Feature exports
```

### `lib/shared/`
Code shared across multiple features:
- Common widgets (buttons, inputs, loading)
- Utility functions
- Common services (API client, storage)
- Extensions

### `lib/core/`
App-level configuration:
- Constants (API URLs, app config)
- Theme configuration
- Route definitions
- App initialization

### `lib/_old_structure/`
**⚠️ DO NOT USE - SCHEDULED FOR DELETION**
Legacy code kept for reference only.

## 🎯 Benefits of New Structure

✅ **Clear Separation of Concerns**
✅ **Feature Independence** - Features can be developed/tested independently
✅ **Scalability** - Easy to add new features
✅ **Maintainability** - Clear where code belongs
✅ **Reusability** - Shared code is clearly defined
✅ **Testability** - Clean architecture makes testing easier
✅ **Onboarding** - New contributors can navigate easily

## 🚀 For New Contributors

### Finding Code:
1. **Looking for a screen?** → Check `lib/features/[feature_name]/presentation/screens/`
2. **Looking for business logic?** → Check `lib/features/[feature_name]/domain/usecases/`
3. **Looking for data models?** → Check `lib/features/[feature_name]/data/models/`
4. **Looking for common widgets?** → Check `lib/shared/widgets/`
5. **Looking for utilities?** → Check `lib/shared/utils/`

### Adding New Code:
1. **New Feature?** → Create in `lib/features/[feature_name]/`
2. **New Screen?** → Add to `lib/features/[feature_name]/presentation/screens/`
3. **New Widget (reusable)?** → Add to `lib/shared/widgets/`
4. **New Widget (feature-specific)?** → Add to `lib/features/[feature_name]/presentation/widgets/`
5. **New Service?** → Add to `lib/shared/services/` or feature-specific

## ⚠️ Important Notes

1. **DO NOT** add new code to `_old_structure/`
2. **DO NOT** create new files in old locations (screen/, widgets/ at root)
3. **DO** follow the feature-based architecture
4. **DO** use the shared folder for truly shared code
5. **DO** keep features independent

## 📅 Timeline

- **Day 1-2**: Move legacy code (DONE ✓)
- **Day 3-5**: Reorganize shared resources
- **Week 2**: Implement clean architecture per feature
- **Week 3**: Update imports across codebase
- **Week 4**: Remove `_old_structure/` after verification

---

**Last Updated**: December 19, 2025
**Status**: Phase 1 Complete ✓

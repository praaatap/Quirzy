# Quirzy - Clean Architecture Guide

## 📁 Project Structure

The project follows **Clean Architecture** principles, separating concerns into distinct layers:

```
lib/
├── core/                    # Core utilities, config, DI
│   ├── config/             # App configuration
│   ├── di/                 # Dependency Injection
│   ├── platform/           # Platform-specific code
│   ├── storage/            # Local storage utilities
│   └── utils/              # Utility functions
│
├── data/                   # DATA LAYER
│   ├── models/             # Data transfer objects (DTOs)
│   ├── datasources/        # Data sources
│   │   ├── remote/         # API calls
│   │   └── local/          # Local storage
│   └── repositories/       # Repository implementations
│
├── domain/                 # DOMAIN LAYER (Business Logic)
│   └── usecases/           # Use cases with business rules
│
├── presentation/           # PRESENTATION LAYER
│   └── providers/          # State management (Riverpod)
│
├── features/               # Feature modules (UI Screens)
│   ├── auth/              # Authentication screens
│   ├── home/              # Home screen
│   ├── quiz/              # Quiz screens
│   ├── flashcards/        # Flashcard screens
│   ├── history/           # Quiz history
│   ├── profile/           # User profile
│   └── settings/          # App settings
│
├── shared/                 # Shared UI components
│   ├── widgets/           # Reusable widgets
│   └── utils/             # UI utilities
│
├── theme/                  # App theming
└── main.dart              # App entry point
```

---

## 🏗️ Architecture Layers

### 1. **Data Layer** (`lib/data/`)
Handles all data operations - fetching from APIs and storing locally.

**Components:**
- **Models**: Data classes that represent API responses
- **Data Sources**: 
  - `Remote`: HTTP API calls
  - `Local`: Secure storage, Hive cache
- **Repositories**: Coordinate between remote and local sources

**Example Flow:**
```
API Response → Remote DataSource → Repository → Use Case → Provider → UI
```

### 2. **Domain Layer** (`lib/domain/`)
Contains business logic and validation rules. This layer is independent of UI and data implementation.

**Components:**
- **Use Cases**: Single-responsibility classes containing business logic
- **Entities**: Core business objects (we use data models for simplicity)

**Key Principles:**
- No Flutter imports (except for debugging)
- Pure Dart code
- All validation happens here

### 3. **Presentation Layer** (`lib/presentation/`)
Handles UI state management and connects UI to domain.

**Components:**
- **Providers**: Riverpod StateNotifiers for state management
- **States**: Immutable state classes

**Note:** Actual screens remain in `features/` folder for feature-based organization.

---

## 🔄 Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│     UI      │ ──▶ │  Provider   │ ──▶ │  Use Case   │ ──▶ │ Repository  │
│  (Screen)   │ ◀── │  (State)    │ ◀── │  (Logic)    │ ◀── │   (Data)    │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
                                                                   │
                                              ┌────────────────────┼────────────────────┐
                                              ▼                    ▼                    ▼
                                        ┌───────────┐        ┌───────────┐        ┌───────────┐
                                        │  Remote   │        │   Local   │        │   Cache   │
                                        │ DataSource│        │ DataSource│        │  (Hive)   │
                                        └───────────┘        └───────────┘        └───────────┘
```

---

## 📦 Import Structure

Use barrel exports for clean imports:

```dart
// Instead of:
import 'package:quirzy/data/models/user_model.dart';
import 'package:quirzy/data/models/quiz_model.dart';

// Use:
import 'package:quirzy/data/data.dart';
```

### Available Barrel Exports:
- `package:quirzy/data/data.dart` - All data layer exports
- `package:quirzy/domain/domain.dart` - All domain layer exports
- `package:quirzy/presentation/presentation.dart` - All presentation exports
- `package:quirzy/core/di/di.dart` - Dependency injection

---

## 🔧 Dependency Injection

Dependencies are provided via Riverpod:

```dart
// In injection_container.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// Usage in widgets
final repository = ref.watch(authRepositoryProvider);
```

---

## ✅ Benefits of This Architecture

1. **Testability**: Each layer can be tested independently
2. **Scalability**: Easy to add new features without affecting existing code
3. **Maintainability**: Clear separation of concerns
4. **Flexibility**: Easy to swap implementations (e.g., different API)
5. **Reusability**: Use cases can be reused across different UI components

---

## 🚀 Quick Start

### Adding a New Feature

1. **Create Model** in `data/models/`
2. **Create Data Source** in `data/datasources/remote/` or `local/`
3. **Create Repository** in `data/repositories/`
4. **Create Use Case** in `domain/usecases/`
5. **Create Provider** in `presentation/providers/`
6. **Create Screen** in `features/{feature_name}/screens/`

### Example: Adding "Leaderboard" Feature

```
lib/
├── data/
│   ├── models/leaderboard_model.dart
│   ├── datasources/remote/leaderboard_remote_datasource.dart
│   └── repositories/leaderboard_repository.dart
├── domain/
│   └── usecases/leaderboard_usecases.dart
├── presentation/
│   └── providers/leaderboard_provider.dart
└── features/
    └── leaderboard/
        └── screens/leaderboard_screen.dart
```

---

## 📝 Migration Notes

The old files in `providers/` and `service/` folders are kept for backward compatibility.
You can gradually migrate to the new structure by:

1. Update imports to use new providers from `presentation/providers/`
2. Test each screen after migration
3. Remove old files once all screens are migrated

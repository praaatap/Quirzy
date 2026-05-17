# Core Layer Structure

```
lib/core/
├── core.dart                      # Barrel export
├── services/
│   ├── services.dart              # Services barrel export
│   ├── core_services.dart         # Re-exports from shared/services
│   └── [additional services]
├── utils/
│   ├── utils.dart                 # Utilities barrel export
│   ├── helpers.dart               # Common helper functions
│   ├── validators.dart            # Input validation
│   ├── extensions.dart            # Dart extensions
│   └── formatters.dart            # Formatting utilities
├── widgets/
│   ├── widgets.dart               # Widgets barrel export
│   ├── common_widgets.dart        # PrimaryButton, StatCard, InfoCard
│   ├── loading_widgets.dart       # LoadingSpinner, SkeletonLoader
│   ├── error_widgets.dart         # Error display
│   └── empty_widgets.dart         # Empty state displays
├── providers/
│   ├── providers.dart             # Providers barrel export
│   └── di/                        # Dependency injection (from lib/core/di)
│       ├── app_providers.dart
│       └── auth_providers.dart
└── constants/                     # (Future: enums, app constants)
```

## Usage

```dart
// Import all core features
import 'package:quirzy/core/core.dart';

// Or import specific parts
import 'package:quirzy/core/utils/helpers.dart';
import 'package:quirzy/core/widgets/common_widgets.dart';
import 'package:quirzy/core/services/services.dart';
```

# 🔧 Duplicate File Removal & Import Fix Plan

## Identified Duplicates

### 1. **ad_service.dart**
- ✅ Keep: `lib/service/ad_service.dart` (3939 bytes)
- ❌ Remove: `lib/shared/services/ad_service.dart` (3939 bytes - identical)

### 2. **api_service.dart**
- ✅ Keep: `lib/service/api_service.dart` (6143 bytes)
- ❌ Remove: `lib/shared/services/api_service.dart` (6139 bytes - nearly identical)

### 3. **notification_service.dart**
- ✅ Keep: `lib/service/notification_service.dart` (10216 bytes)
- ❌ Remove: `lib/shared/services/notification_service.dart` (10216 bytes - identical)

### 4. **quiz_service.dart**
- ✅ Keep: `lib/features/quiz/services/quiz_service.dart` (feature-specific)
- ❌ Remove: `lib/service/quiz_service.dart` (old location)

### 5. **profile_service.dart**
- ✅ Keep: `lib/features/profile/services/profile_service.dart` (feature-specific)
- ❌ Remove: `lib/service/profile.service.dart` (old location, wrong naming)

### 6. **cache_service.dart**
- ✅ Keep: `lib/core/storage/hive_cache_service.dart` (proper location)
- ❌ Remove: `lib/service/cache_service.dart` (old location)

### 7. **user_data_service.dart**
- ✅ Keep: `lib/service/user_data_service.dart` (no duplicate, keep as is)

## Actions Required

### Step 1: Remove Duplicate Files
```powershell
Remove-Item "lib/shared/services/ad_service.dart"
Remove-Item "lib/shared/services/api_service.dart"
Remove-Item "lib/shared/services/notification_service.dart"
Remove-Item "lib/service/quiz_service.dart"
Remove-Item "lib/service/profile.service.dart"
Remove-Item "lib/service/cache_service.dart"
```

### Step 2: Update Imports

#### For quiz_service.dart:
**Old:** `import 'package:quirzy/service/quiz_service.dart';`  
**New:** `import 'package:quirzy/features/quiz/services/quiz_service.dart';`

**Files to Update:**
- `lib/providers/quiz_history_provider.dart`
- `lib/features/history/providers/quiz_history_provider.dart`
- `lib/features/home/screens/home_screen.dart`
- `lib/features/quiz/screens/quiz_completed_screen.dart`

#### For cache_service.dart:
**Old:** `import 'package:quirzy/service/cache_service.dart';`  
**New:** `import 'package:quirzy/core/storage/hive_cache_service.dart';`

**Files to Update:**
- `lib/main.dart`
- `lib/providers/quiz_history_provider.dart`
- `lib/features/history/providers/quiz_history_provider.dart`

### Step 3: Keep As-Is (Already Correct)
- `lib/service/ad_service.dart`
- `lib/service/api_service.dart`
- `lib/service/notification_service.dart`
- `lib/service/user_data_service.dart`

## Final Structure

```
lib/service/                          # Shared services
├── ad_service.dart                   ✅ Keep
├── api_service.dart                  ✅ Keep
├── notification_service.dart         ✅ Keep
└── user_data_service.dart            ✅ Keep

lib/features/quiz/services/           # Quiz-specific
└── quiz_service.dart                 ✅ Keep

lib/features/profile/services/        # Profile-specific
└── profile_service.dart              ✅ Keep

lib/core/storage/                     # Core storage
└── hive_cache_service.dart           ✅ Keep

lib/shared/services/                  # TO BE DELETED
├── ad_service.dart                   ❌ Delete (duplicate)
├── api_service.dart                  ❌ Delete (duplicate)
├── notification_service.dart         ❌ Delete (duplicate)
└── services.dart                     ❌ Delete (not used)
```

## Execution Order
1. ✅ Update all import statements
2. ✅ Remove duplicate files
3. ✅ Test app compilation
4. ✅ Run app to verify

---
**Status:** Ready to execute

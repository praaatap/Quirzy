# Appwrite Database Setup Script
# Run this to create the daily_quizzes collection and required indexes
# 
# Prerequisites:
# 1. Install Appwrite CLI: https://appwrite.io/docs/command-line
# 2. Login: appwrite login
# 3. Set project: appwrite init
#
# Then run: appwrite create collection --input-file setup_daily_quizzes.json

---

## Manual Setup Instructions (Appwrite Console)

### Step 1: Create Collection

1. Go to: https://cloud.appwrite.io
2. Select your project: `695be801003d58b523fc`
3. Navigate to **Database** → Select database: `695d45fe000f2d83ddee`
4. Click **Create Collection**
5. Enter:
   - **Collection ID**: `daily_quizzes`
   - **Name**: Daily Quizzes
   - **Permissions**: 
     - Create: `users`
     - Read: `users`
     - Update: `users`
     - Delete: `users`
6. Click **Create**

---

### Step 2: Add Attributes

Click on the `daily_quizzes` collection, then add these attributes:

#### Attribute 1: userId
- **Type**: String
- **Key**: `userId`
- **Size**: 255
- **Required**: ✅ Yes
- **Default**: (leave empty)

#### Attribute 2: date
- **Type**: String
- **Key**: `date`
- **Size**: 10
- **Required**: ✅ Yes
- **Default**: (leave empty)

#### Attribute 3: quizId
- **Type**: String
- **Key**: `quizId`
- **Size**: 255
- **Required**: ✅ Yes
- **Default**: (leave empty)

#### Attribute 4: topic
- **Type**: String
- **Key**: `topic`
- **Size**: 255
- **Required**: ✅ Yes
- **Default**: (leave empty)

#### Attribute 5: createdAt
- **Type**: Datetime
- **Key**: `createdAt`
- **Required**: ✅ Yes
- **Default**: (leave empty)

---

### Step 3: Create Indexes

#### Index 1: userId_date (Compound Index)
- Click **Indexes** tab
- Click **Create Index**
- **Index Key**: `userId_date`
- **Type**: Key
- **Attributes**: 
  - `userId` (ASC)
  - `date` (ASC)
- Click **Create**

#### Index 2: userId_only
- Click **Create Index**
- **Index Key**: `userId_only`
- **Type**: Key
- **Attributes**: 
  - `userId` (ASC)
- Click **Create**

---

### Step 4: Set Permissions

Make sure the collection has these permissions:

```json
{
  "$collection": "daily_quizzes",
  "permissions": [
    "create(\"users\")",
    "read(\"users\")",
    "update(\"users\")",
    "delete(\"users\")"
  ]
}
```

This ensures users can only access their own documents.

---

## Recommended Indexes for Existing Collections

### quiz_results Collection

Add these indexes for better analytics performance:

#### Index 1: userId_createdAt
- **Key**: `userId_createdAt`
- **Type**: Key
- **Attributes**: 
  - `userId` (ASC)
  - `createdAt` (DESC)

#### Index 2: userId_percentage
- **Key**: `userId_percentage`
- **Type**: Key
- **Attributes**: 
  - `userId` (ASC)
  - `percentage` (ASC)

---

### users Collection

Verify the `quizCount` attribute exists:

- **Type**: Integer
- **Key**: `quizCount`
- **Required**: No
- **Default**: 0

Add index:
- **Key**: `quizCount_index`
- **Type**: Key
- **Attributes**: `quizCount` (ASC)

---

## Verification

After setup, test with this Flutter code:

```dart
import 'package:quirzy/features/quiz/services/services.dart';

void main() async {
  final service = DailyQuizService();
  
  // Should return true (no quiz today)
  final canGenerate = await service.canGenerateQuiz();
  print('Can generate quiz: $canGenerate');
  
  // Should return 0
  final todayCount = await service.getTodayQuizCount();
  print('Today quiz count: $todayCount');
  
  // Get total
  final total = await service.getTotalQuizCount();
  print('Total quizzes: $total');
}
```

---

## Troubleshooting

### Collection creation fails
- Ensure you're logged in to Appwrite
- Verify project ID is correct
- Check database exists: `695d45fe000f2d83ddee`

### Index creation fails
- Wait for attributes to be available (can take a few seconds)
- Ensure attribute names match exactly
- Check attribute types are correct

### Permission errors
- Ensure `users` role is configured
- Verify collection permissions are set
- Check document-level permissions if needed

---

## Quick Setup via Appwrite CLI (Alternative)

If you prefer using the CLI:

```bash
# Login first
appwrite login

# Initialize project
appwrite init

# Create collection
appwrite databases createCollection \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --name "Daily Quizzes" \
  --permissions '["create(\"users\")", "read(\"users\")", "update(\"users\")", "delete(\"users\")"]'

# Add attributes
appwrite databases createStringAttribute \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key userId \
  --size 255 \
  --required true

appwrite databases createStringAttribute \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key date \
  --size 10 \
  --required true

appwrite databases createStringAttribute \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key quizId \
  --size 255 \
  --required true

appwrite databases createStringAttribute \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key topic \
  --size 255 \
  --required true

appwrite databases createDatetimeAttribute \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key createdAt \
  --required true

# Create indexes
appwrite databases createIndex \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key userId_date \
  --type key \
  --attributes '["userId", "date"]' \
  --orders '["ASC", "ASC"]'

appwrite databases createIndex \
  --database-id 695d45fe000f2d83ddee \
  --collection-id daily_quizzes \
  --key userId_only \
  --type key \
  --attributes '["userId"]' \
  --orders '["ASC"]'
```

---

**Important**: After creating the collection, update the `daily_quizzes` collection ID in the code if it differs from the collection name.

Current code expects: `daily_quizzes` (same as collection ID)

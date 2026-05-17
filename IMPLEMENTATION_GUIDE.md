# Quirzy App - Implementation Guide

## 📊 New Features Implemented

### 1. **Daily Free Quiz System** ✅
- **Feature**: Users get 1 free quiz per day
- **Implementation**:
  - Tracks quiz usage via Appwrite `daily_quizzes` collection
  - Local caching via SharedPreferences for quick checks
  - Automatic daily reset at midnight
  - User-friendly dialog when limit is reached

### 2. **Quiz Analytics Dashboard** ✅
- **Feature**: Comprehensive performance tracking and visualization
- **Components**:
  - **Overview Tab**:
    - Daily quiz status card
    - Overall performance metrics (average, best, total)
    - Performance trend (improving/declining)
    - Score chart (last 10 quizzes)
  
  - **Topics Tab**:
    - Strong areas (>80% accuracy)
    - Weak areas (<60% accuracy)
    - All topics with accuracy percentages
    - Topic-wise quiz counts
  
  - **History Tab**:
    - Recent quiz performances (last 100)
    - Score, date, and topic details
    - Color-coded performance indicators

### 3. **Enhanced User Tracking** ✅
- Automatic `quizCount` increment in users collection
- Daily quiz usage recording
- Total and weekly quiz statistics

---

## 📁 New Files Created

### Services
1. `lib/features/quiz/services/daily_quiz_service.dart`
   - Manages daily quiz limits
   - Records quiz usage
   - Provides quiz statistics

2. `lib/features/quiz/services/quiz_analytics_service.dart`
   - Fetches comprehensive analytics
   - Calculates topic performance
   - Identifies weak/strong areas
   - Tracks performance trends

### Providers
3. `lib/features/quiz/providers/daily_quiz_provider.dart`
   - Riverpod providers for daily quiz features
   - `canGenerateQuizProvider`
   - `todayQuizCountProvider`
   - `totalQuizCountProvider`
   - `quizStatsProvider`

4. `lib/features/quiz/providers/quiz_analytics_provider.dart`
   - Riverpod providers for analytics
   - `quizAnalyticsProvider`
   - `topicPerformanceProvider`
   - `recentPerformanceProvider`
   - `performanceTrendProvider`
   - `weakAreasProvider`
   - `strongAreasProvider`

### Screens
5. `lib/features/quiz/screens/analytics_dashboard_screen.dart`
   - Beautiful analytics visualization
   - 3-tab interface (Overview, Topics, History)
   - Uses fl_chart for score graphs
   - Color-coded performance metrics

---

## 🗄️ Required Appwrite Database Changes

### **NEW COLLECTION: `daily_quizzes`**

You need to create this collection in your Appwrite database:

**Collection ID**: `daily_quizzes`

**Attributes**:
| Attribute | Type | Size | Required | Description |
|-----------|------|------|----------|-------------|
| `userId` | string | 255 | ✅ | User ID (references users collection) |
| `date` | string | 10 | ✅ | Date in YYYY-MM-DD format |
| `quizId` | string | 255 | ✅ | Generated quiz ID |
| `topic` | string | 255 | ✅ | Quiz topic |
| `createdAt` | datetime | - | ✅ | Timestamp of creation |

**Indexes**:
```
1. userId_date (compound index)
   - Type: key
   - Attributes: userId (ASC), date (ASC)
   - Purpose: Fast lookup for daily limit checks

2. userId_only
   - Type: key
   - Attribute: userId
   - Purpose: Fast user statistics queries
```

**Permissions**:
- Create: Users with `users` role
- Read: Users with `users` role (own documents only)
- Update: Users with `users` role (own documents only)
- Delete: Users with `users` role (own documents only)

---

## 📈 Recommended Indexes for Existing Collections

### **quiz_results Collection**
Add these indexes for better analytics performance:

```
1. userId_createdAt (compound)
   - Type: key
   - Attributes: userId (ASC), createdAt (DESC)
   - Purpose: Fast quiz history retrieval

2. userId_percentage
   - Type: key
   - Attributes: userId (ASC), percentage (ASC)
   - Purpose: Performance-based queries
```

### **users Collection**
The `quizCount` field already exists but ensure it has:

```
1. quizCount index
   - Type: key
   - Attribute: quizCount
   - Purpose: Leaderboard and statistics queries
```

---

## 🚀 How to Use

### **For Users**:
1. **Generate Quiz**: 
   - Go to Home screen
   - Enter topic and tap "Generate Quiz"
   - System checks if you've used your daily quiz
   - If available, generates quiz
   - If not, shows upgrade dialog

2. **View Analytics**:
   - Go to Profile → Data & Privacy → Quiz Analytics
   - Or navigate directly to `/analytics` route
   - View comprehensive performance data

### **For Developers**:

#### Check Daily Quiz Limit:
```dart
final canGenerate = await ref.read(canGenerateQuizProvider.future);
if (!canGenerate) {
  // Show limit reached dialog
}
```

#### Get Quiz Statistics:
```dart
final stats = await ref.read(quizStatsProvider.future);
// stats['todayUsed'] - bool
// stats['thisWeek'] - int
// stats['total'] - int
```

#### Get Analytics:
```dart
final analytics = await ref.read(quizAnalyticsProvider.future);
// analytics.averageScore
// analytics.totalQuizzes
// analytics.bestScore
// analytics.results (list of quiz results)
```

---

## 🔧 Integration Points

### **Home Screen** (`lib/home/screens/home_screen.dart`)
- Modified `_startGeneration()` method
- Checks `canGenerateQuizProvider` before quiz generation
- Records usage via `dailyQuizService.recordDailyQuizUsage()`

### **Profile Screen** (`lib/profile/screens/profile_screen.dart`)
- Added "Quiz Analytics" option in Data & Privacy section
- Navigates to `/analytics` route

### **Router** (`lib/routes/router.dart`)
- Added analytics route
- Import for `AnalyticsDashboardScreen`

---

## 🎨 UI/UX Features

### Analytics Dashboard
- **Tab-based navigation** (Overview, Topics, History)
- **Color-coded metrics**:
  - 🟢 Green: >80% or improving
  - 🟠 Orange: 50-80% or stable
  - 🔴 Red: <50% or declining
- **Interactive charts** using fl_chart
- **Responsive design** with dark mode support
- **Loading states** with skeleton loaders
- **Error handling** with graceful fallbacks

### Daily Quiz Dialog
- Clear messaging about daily limit
- Call-to-action for Pro upgrade
- Non-intrusive implementation

---

## 📊 Analytics Features

### Performance Tracking
1. **Overall Metrics**:
   - Average score across all quizzes
   - Best and worst scores
   - Total time spent
   - Total quizzes completed

2. **Trend Analysis**:
   - Compares last 7 quizzes vs previous 7
   - Shows improving/declining trend
   - Percentage change calculation

3. **Topic Analysis**:
   - Per-topic accuracy
   - Strong areas (>80%)
   - Weak areas (<60%)
   - Quiz count per topic
   - Trend per topic (improving/stable/declining)

4. **Recent Performance**:
   - Last 100 quiz results
   - Score history chart (last 10)
   - Date and time tracking

---

## 🔐 Security Considerations

- **User isolation**: All queries filtered by `userId`
- **Data validation**: Proper error handling in all services
- **Local caching**: SharedPreferences for non-sensitive data
- **Appwrite permissions**: Row-level security via user roles

---

## 🐛 Known Limitations

1. **Daily Reset Time**: Currently resets at midnight local time
2. **Offline Mode**: Analytics require internet connection
3. **Topic Extraction**: Simple split by space (can be improved with NLP)
4. **Historical Data**: Existing quiz results don't have daily tracking

---

## 🎯 Future Enhancements

1. **Streak Tracking**: Daily quiz completion streaks
2. **Leaderboards**: Compare with other users
3. **Goals**: Set and track learning goals
4. **Export**: Download analytics as PDF/CSV
5. **Predictions**: AI-powered performance predictions
6. **Custom Periods**: Date range filters for analytics
7. **Pro Tier**: Unlimited quizzes with subscription

---

## 📝 Testing Checklist

- [ ] Create `daily_quizzes` collection in Appwrite
- [ ] Add indexes to existing collections
- [ ] Test daily quiz limit enforcement
- [ ] Verify analytics data accuracy
- [ ] Test dark/light mode in analytics screen
- [ ] Check performance with 100+ quiz results
- [ ] Verify user data isolation (can't see others' data)
- [ ] Test error states (no data, network errors)
- [ ] Confirm quizCount increments properly
- [ ] Test route navigation to analytics

---

## 🛠️ Troubleshooting

### "Daily quiz check fails"
- Ensure `daily_quizzes` collection exists
- Check Appwrite permissions
- Verify indexes are created

### "Analytics show no data"
- Complete at least 1 quiz
- Check `quiz_results` collection has data
- Verify userId matches

### "quizCount not incrementing"
- Check Appwrite user document permissions
- Ensure `users` collection exists
- Verify field name matches (`quizCount`)

---

## 📞 Support

For issues or questions:
1. Check Appwrite console for errors
2. Verify collection structure matches this guide
3. Check Flutter console for debug logs
4. Review Riverpod provider states in DevTools

---

**Last Updated**: April 12, 2026
**Version**: 2.2.0
**Appwrite Project**: 695be801003d58b523fc

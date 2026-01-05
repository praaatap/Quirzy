import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to manage daily login streaks and XP rewards
/// Tracks consecutive days the user logs in and awards XP
class DailyStreakService {
  static final DailyStreakService _instance = DailyStreakService._internal();
  factory DailyStreakService() => _instance;
  DailyStreakService._internal();

  Box? _box;

  // Keys for Hive storage
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _longestStreakKey = 'longest_streak';
  static const String _totalXPKey = 'total_xp';
  static const String _loginDatesKey = 'login_dates'; // For calendar heatmap

  // XP Reward configuration
  static const int baseXP = 10;
  static const int streakBonusXP = 5; // Additional XP per streak day

  /// Initialize the service
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('streak_data');
    debugPrint('🔥 Daily Streak Service initialized');
  }

  /// Record a login and update streak
  /// Returns the XP earned for this login (0 if already logged in today)
  Future<int> recordLogin() async {
    if (_box == null) await initialize();

    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final lastLoginStr = _box!.get(_lastLoginDateKey, defaultValue: '');

    // Already logged in today
    if (lastLoginStr == todayStr) {
      debugPrint('📅 Already logged in today');
      return 0;
    }

    int currentStreak = _box!.get(_currentStreakKey, defaultValue: 0);
    int longestStreak = _box!.get(_longestStreakKey, defaultValue: 0);

    if (lastLoginStr.isNotEmpty) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final daysDifference = today.difference(lastLogin).inDays;

      if (daysDifference == 1) {
        // Consecutive day - increase streak
        currentStreak++;
        debugPrint('🔥 Streak continued: $currentStreak days');
      } else if (daysDifference > 1) {
        // Streak broken - reset
        currentStreak = 1;
        debugPrint('💔 Streak broken, starting fresh');
      }
    } else {
      // First login ever
      currentStreak = 1;
      debugPrint('🎉 First login! Starting streak');
    }

    // Update longest streak
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Calculate XP reward
    final xpEarned = baseXP + (currentStreak * streakBonusXP);
    final totalXP = _box!.get(_totalXPKey, defaultValue: 0) + xpEarned;

    // Update login dates for calendar heatmap
    await _addLoginDate(todayStr);

    // Save all data
    await _box!.put(_lastLoginDateKey, todayStr);
    await _box!.put(_currentStreakKey, currentStreak);
    await _box!.put(_longestStreakKey, longestStreak);
    await _box!.put(_totalXPKey, totalXP);

    debugPrint('✨ Earned $xpEarned XP! Total: $totalXP');

    return xpEarned;
  }

  /// Add login date to the calendar history
  Future<void> _addLoginDate(String dateStr) async {
    final List<dynamic> dates = _box!.get(
      _loginDatesKey,
      defaultValue: <dynamic>[],
    );
    if (!dates.contains(dateStr)) {
      dates.add(dateStr);
      // Keep only last 365 days
      if (dates.length > 365) {
        dates.removeAt(0);
      }
      await _box!.put(_loginDatesKey, dates);
    }
  }

  /// Get current streak
  int getCurrentStreak() {
    if (_box == null) return 0;

    // Check if streak is still valid (logged in today or yesterday)
    final lastLoginStr = _box!.get(_lastLoginDateKey, defaultValue: '');
    if (lastLoginStr.isEmpty) return 0;

    final today = DateTime.now();
    final todayStr = _formatDate(today);
    final yesterdayStr = _formatDate(today.subtract(const Duration(days: 1)));

    if (lastLoginStr != todayStr && lastLoginStr != yesterdayStr) {
      // Streak is broken
      return 0;
    }

    return _box!.get(_currentStreakKey, defaultValue: 0);
  }

  /// Get longest streak ever achieved
  int getLongestStreak() {
    if (_box == null) return 0;
    return _box!.get(_longestStreakKey, defaultValue: 0);
  }

  /// Get total XP earned
  int getTotalXP() {
    if (_box == null) return 0;
    return _box!.get(_totalXPKey, defaultValue: 0);
  }

  /// Get login dates for calendar heatmap (last N days)
  Map<DateTime, int> getLoginHeatmap({int days = 70}) {
    if (_box == null) return {};

    final List<dynamic> loginDates = _box!.get(
      _loginDatesKey,
      defaultValue: <dynamic>[],
    );
    final Map<DateTime, int> heatmap = {};

    final today = DateTime.now();
    final cutoffDate = today.subtract(Duration(days: days));

    for (final dateStr in loginDates) {
      try {
        final date = DateTime.parse(dateStr as String);
        if (date.isAfter(cutoffDate)) {
          final normalized = DateTime(date.year, date.month, date.day);
          heatmap[normalized] = 1; // 1 login per day
        }
      } catch (e) {
        debugPrint('Error parsing date: $dateStr');
      }
    }

    return heatmap;
  }

  /// Check if user has logged in today
  bool hasLoggedInToday() {
    if (_box == null) return false;
    final lastLoginStr = _box!.get(_lastLoginDateKey, defaultValue: '');
    final todayStr = _formatDate(DateTime.now());
    return lastLoginStr == todayStr;
  }

  /// Get streak data summary
  Map<String, dynamic> getStreakSummary() {
    return {
      'currentStreak': getCurrentStreak(),
      'longestStreak': getLongestStreak(),
      'totalXP': getTotalXP(),
      'hasLoggedInToday': hasLoggedInToday(),
      'nextXPReward': hasLoggedInToday()
          ? 0
          : baseXP + ((getCurrentStreak() + 1) * streakBonusXP),
    };
  }

  /// Format date as YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

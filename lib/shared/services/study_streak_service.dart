import 'package:shared_preferences/shared_preferences.dart';

/// Study Streak Service - Tracks daily learning streaks
/// Features:
/// - Tracks consecutive days of app usage
/// - Calculates streak count and best streak
/// - Provides daily login rewards
/// - Shows streak calendar visualization data
class StudyStreakService {
  static StudyStreakService? _instance;
  static const String _lastLoginKey = 'last_login_date';
  static const String _streakCountKey = 'current_streak';
  static const String _bestStreakKey = 'best_streak';
  static const String _totalLoginsKey = 'total_logins';
  static const String _loginHistoryKey = 'login_history';

  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalLogins = 0;
  Map<String, bool> _loginHistory = {};

  factory StudyStreakService() {
    _instance ??= StudyStreakService._internal();
    return _instance!;
  }

  StudyStreakService._internal();

  static Future<void> init() async {
    await StudyStreakService()._loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt(_streakCountKey) ?? 0;
    _bestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    _totalLogins = prefs.getInt(_totalLoginsKey) ?? 0;
    
    final historyMap = prefs.getKeys().contains(_loginHistoryKey)
        ? prefs.getString(_loginHistoryKey)
        : null;
    if (historyMap != null) {
      _loginHistory = Map<String, bool>.fromEntries(
        historyMap.split(',').map((e) {
          final parts = e.split(':');
          return MapEntry(parts[0], parts[1] == 'true');
        }),
      );
    }
  }

  /// Record today's login and update streak
  Future<StreakUpdate> recordLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateToString(DateTime.now());
    final yesterday = _dateToString(DateTime.now().subtract(const Duration(days: 1)));

    // Check if already logged in today
    if (_loginHistory[today] == true) {
      return StreakUpdate(
        currentStreak: _currentStreak,
        bestStreak: _bestStreak,
        isNewDay: false,
        streakIncreased: false,
        xpReward: 0,
      );
    }

    // Mark today as logged in
    _loginHistory[today] = true;
    _totalLogins++;
    await prefs.setInt(_totalLoginsKey, _totalLogins);

    // Update streak
    bool streakIncreased = false;
    if (_loginHistory[yesterday] == true || _currentStreak == 0) {
      // Continuation of streak or first login
      _currentStreak++;
      streakIncreased = true;
    } else {
      // Streak broken, restart from 1
      _currentStreak = 1;
    }

    // Update best streak
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
      await prefs.setInt(_bestStreakKey, _bestStreak);
    }

    // Save streak count
    await prefs.setInt(_streakCountKey, _currentStreak);
    await prefs.setString(_lastLoginKey, today);

    // Calculate XP reward (increases with streak)
    final xpReward = _calculateXPReward(_currentStreak);

    // Save login history (keep last 90 days)
    await _saveLoginHistory(prefs);

    return StreakUpdate(
      currentStreak: _currentStreak,
      bestStreak: _bestStreak,
      isNewDay: true,
      streakIncreased: streakIncreased,
      xpReward: xpReward,
    );
  }

  int _calculateXPReward(int streak) {
    // Base 10 XP + bonus for streaks
    if (streak == 1) return 10;
    if (streak <= 7) return 10 + (streak * 2); // 14-24 XP for week 1
    if (streak <= 30) return 30 + (streak); // 31-60 XP for month 1
    return 100; // 100 XP for legendary streaks
  }

  Future<void> _saveLoginHistory(SharedPreferences prefs) async {
    // Keep only last 90 days
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    _loginHistory.removeWhere((date, _) {
      final parsed = _stringToDate(date);
      return parsed.isBefore(cutoff);
    });

    final historyString = _loginHistory.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');
    await prefs.setString(_loginHistoryKey, historyString);
  }

  /// Get streak data for calendar visualization (last 90 days)
  Map<String, dynamic> getStreakCalendarData() {
    final now = DateTime.now();
    final data = <String, bool>{};
    
    for (int i = 89; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _dateToString(date);
      data[dateStr] = _loginHistory[dateStr] ?? false;
    }

    return {
      'history': data,
      'currentStreak': _currentStreak,
      'bestStreak': _bestStreak,
      'totalLogins': _totalLogins,
    };
  }

  /// Get motivational message based on streak
  String getMotivationalMessage() {
    if (_currentStreak == 0) return 'Start your learning journey today! 🔥';
    if (_currentStreak == 1) return 'Day 1! The journey begins! 🌟';
    if (_currentStreak <= 3) return 'Building momentum! Keep going! 💪';
    if (_currentStreak <= 7) return 'Week warrior! You\'re on fire! 🔥🔥';
    if (_currentStreak <= 14) return 'Two weeks strong! Amazing dedication! ⭐';
    if (_currentStreak <= 30) return 'Monthly master! Incredible commitment! 🏆';
    if (_currentStreak <= 60) return 'Legendary learner! You inspire us all! 👑';
    return 'Mythical streak! You are learning itself! 🌟🌟🌟';
  }

  /// Get streak emoji
  String getStreakEmoji() {
    if (_currentStreak == 0) return '📚';
    if (_currentStreak == 1) return '🌱';
    if (_currentStreak <= 3) return '🔥';
    if (_currentStreak <= 7) return '🔥🔥';
    if (_currentStreak <= 14) return '⭐';
    if (_currentStreak <= 30) return '🏆';
    if (_currentStreak <= 60) return '👑';
    return '🌟🌟🌟';
  }

  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get totalLogins => _totalLogins;

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _stringToDate(String str) {
    final parts = str.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}

/// Result of a streak login
class StreakUpdate {
  final int currentStreak;
  final int bestStreak;
  final bool isNewDay;
  final bool streakIncreased;
  final int xpReward;

  const StreakUpdate({
    required this.currentStreak,
    required this.bestStreak,
    required this.isNewDay,
    required this.streakIncreased,
    required this.xpReward,
  });
}

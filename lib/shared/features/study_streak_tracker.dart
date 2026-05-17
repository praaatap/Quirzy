import 'package:shared_preferences/shared_preferences.dart';

/// Feature 3: Study Streak Tracker
/// Visual streak tracking with milestones
class StudyStreakTracker {
  static StudyStreakTracker? _instance;
  
  static const String _streakKey = 'study_streak';
  static const String _lastStudyKey = 'last_study_date';
  static const String _bestStreakKey = 'best_study_streak';
  static const String _streakHistoryKey = 'streak_history';

  factory StudyStreakTracker() {
    _instance ??= StudyStreakTracker._internal();
    return _instance!;
  }

  StudyStreakTracker._internal();

  /// Record today's study session
  Future<StreakResult> recordStudy() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
    
    final lastStudy = prefs.getString(_lastStudyKey);
    int currentStreak = prefs.getInt(_streakKey) ?? 0;
    int bestStreak = prefs.getInt(_bestStreakKey) ?? 0;

    bool isNewDay = lastStudy != today;
    bool streakContinues = lastStudy == yesterday || currentStreak == 0;

    if (isNewDay) {
      if (streakContinues) {
        currentStreak++;
      } else {
        currentStreak = 1; // Reset streak
      }

      await prefs.setInt(_streakKey, currentStreak);
      await prefs.setString(_lastStudyKey, today);

      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
        await prefs.setInt(_bestStreakKey, bestStreak);
      }

      // Add to history
      await _addToHistory(today);
    }

    return StreakResult(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      isNewDay: isNewDay,
      milestone: _getMilestone(currentStreak),
      xpBonus: _calculateXPBonus(currentStreak),
    );
  }

  /// Get current streak info
  Future<StreakInfo> getStreakInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return StreakInfo(
      currentStreak: prefs.getInt(_streakKey) ?? 0,
      bestStreak: prefs.getInt(_bestStreakKey) ?? 0,
      lastStudyDate: prefs.getString(_lastStudyKey),
    );
  }

  /// Get streak history (last 30 days)
  Future<Map<String, bool>> getStreakHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_streakHistoryKey) ?? [];
    
    return Map.fromEntries(
      history.map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], parts[1] == '1');
      }),
    );
  }

  Future<void> _addToHistory(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_streakHistoryKey) ?? [];
    
    // Remove old entry if exists
    history.removeWhere((e) => e.startsWith('$dateKey:'));
    
    // Add new entry
    history.add('$dateKey:1');
    
    // Keep only last 90 days
    if (history.length > 90) {
      history.removeRange(0, history.length - 90);
    }
    
    await prefs.setStringList(_streakHistoryKey, history);
  }

  String _getMilestone(int streak) {
    if (streak == 1) return 'First Step! 🌟';
    if (streak == 3) return 'Hat Trick! 🔥';
    if (streak == 7) return 'Week Warrior! ⭐';
    if (streak == 14) return 'Fortnight Legend! 🏆';
    if (streak == 30) return 'Monthly Master! 👑';
    if (streak == 60) return 'Bimonthly Boss! 💎';
    if (streak == 100) return 'Century Champion! 🌟🌟🌟';
    return '';
  }

  int _calculateXPBonus(int streak) {
    if (streak <= 7) return 10 + (streak * 2);
    if (streak <= 30) return 30 + streak;
    return 100;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class StreakResult {
  final int currentStreak;
  final int bestStreak;
  final bool isNewDay;
  final String milestone;
  final int xpBonus;

  const StreakResult({
    required this.currentStreak,
    required this.bestStreak,
    required this.isNewDay,
    required this.milestone,
    required this.xpBonus,
  });
}

class StreakInfo {
  final int currentStreak;
  final int bestStreak;
  final String? lastStudyDate;

  const StreakInfo({
    required this.currentStreak,
    required this.bestStreak,
    this.lastStudyDate,
  });
}

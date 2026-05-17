import 'package:shared_preferences/shared_preferences.dart';

/// Feature 6: Daily Rewards Service
/// Login bonuses and streak rewards
class DailyRewardsService {
  static DailyRewardsService? _instance;
  
  static const String _lastClaimKey = 'last_reward_claim';
  static const String _consecutiveDaysKey = 'consecutive_reward_days';
  
  // 7-day reward cycle
  static const List<DailyReward> rewardCycle = [
    DailyReward(day: 1, xp: 10, coins: 50, message: 'Day 1: Welcome back! 🌟'),
    DailyReward(day: 2, xp: 20, coins: 75, message: 'Day 2: Keep it going! 🔥'),
    DailyReward(day: 3, xp: 30, coins: 100, message: 'Day 3: You\'re on fire! ⭐'),
    DailyReward(day: 4, xp: 40, coins: 125, message: 'Day 4: Almost there! 💪'),
    DailyReward(day: 5, xp: 50, coins: 150, message: 'Day 5: So close! 🎯'),
    DailyReward(day: 6, xp: 60, coins: 175, message: 'Day 6: One more day! 🏆'),
    DailyReward(day: 7, xp: 100, coins: 500, message: 'Day 7: Weekly Champion! 👑💎'),
  ];

  factory DailyRewardsService() {
    _instance ??= DailyRewardsService._internal();
    return _instance!;
  }

  DailyRewardsService._internal();

  /// Claim daily reward
  Future<ClaimResult> claimDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _dateKey(DateTime.now());
    final lastClaim = prefs.getString(_lastClaimKey);

    // Already claimed today
    if (lastClaim == today) {
      return ClaimResult(
        canClaim: false,
        message: 'Already claimed today\'s reward!',
        nextClaimIn: _timeUntilMidnight(),
      );
    }

    // Calculate consecutive days
    int consecutiveDays = prefs.getInt(_consecutiveDaysKey) ?? 0;
    final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));

    if (lastClaim == yesterday) {
      consecutiveDays++;
      if (consecutiveDays > 7) consecutiveDays = 1; // Reset after day 7
    } else {
      consecutiveDays = 1; // Reset streak
    }

    final reward = rewardCycle[consecutiveDays - 1];

    // Save claim
    await prefs.setString(_lastClaimKey, today);
    await prefs.setInt(_consecutiveDaysKey, consecutiveDays);

    return ClaimResult(
      canClaim: true,
      reward: reward,
      message: reward.message,
      nextDay: (consecutiveDays % 7) + 1,
    );
  }

  /// Get current reward status
  Future<RewardStatus> getRewardStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final consecutiveDays = prefs.getInt(_consecutiveDaysKey) ?? 0;
    final lastClaim = prefs.getString(_lastClaimKey);
    final today = _dateKey(DateTime.now());

    final canClaim = lastClaim != today;
    final currentDay = (consecutiveDays % 7) + 1;
    final currentReward = rewardCycle[currentDay - 1];

    return RewardStatus(
      canClaim: canClaim,
      currentDay: currentDay,
      currentReward: currentReward,
      consecutiveDays: consecutiveDays,
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Duration _timeUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }
}

class DailyReward {
  final int day;
  final int xp;
  final int coins;
  final String message;

  const DailyReward({
    required this.day,
    required this.xp,
    required this.coins,
    required this.message,
  });
}

class ClaimResult {
  final bool canClaim;
  final DailyReward? reward;
  final String message;
  final int? nextDay;
  final Duration? nextClaimIn;

  const ClaimResult({
    required this.canClaim,
    this.reward,
    required this.message,
    this.nextDay,
    this.nextClaimIn,
  });
}

class RewardStatus {
  final bool canClaim;
  final int currentDay;
  final DailyReward currentReward;
  final int consecutiveDays;

  const RewardStatus({
    required this.canClaim,
    required this.currentDay,
    required this.currentReward,
    required this.consecutiveDays,
  });
}

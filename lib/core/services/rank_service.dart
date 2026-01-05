import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Rank System Service - PUBG/Free Fire Style Ranking
/// Manages user ranks, XP progression, and rank-up events
class RankService {
  static final RankService _instance = RankService._internal();
  factory RankService() => _instance;
  RankService._internal();

  Box? _box;

  // Storage Keys
  static const String _totalXPKey = 'total_xp';
  static const String _currentRankKey = 'current_rank';
  static const String _previousRankKey = 'previous_rank';
  static const String _rankUpPendingKey = 'rank_up_pending';

  /// All available ranks in order (like PUBG/Free Fire)
  static const List<RankTier> allRanks = [
    RankTier(
      id: 'bronze_1',
      name: 'Bronze I',
      tier: 'Bronze',
      division: 1,
      minXP: 0,
      maxXP: 99,
      iconPath: '🥉',
      color: 0xFFCD7F32,
      glowColor: 0xFFB87333,
    ),
    RankTier(
      id: 'bronze_2',
      name: 'Bronze II',
      tier: 'Bronze',
      division: 2,
      minXP: 100,
      maxXP: 249,
      iconPath: '🥉',
      color: 0xFFCD7F32,
      glowColor: 0xFFB87333,
    ),
    RankTier(
      id: 'bronze_3',
      name: 'Bronze III',
      tier: 'Bronze',
      division: 3,
      minXP: 250,
      maxXP: 499,
      iconPath: '🥉',
      color: 0xFFCD7F32,
      glowColor: 0xFFB87333,
    ),
    RankTier(
      id: 'silver_1',
      name: 'Silver I',
      tier: 'Silver',
      division: 1,
      minXP: 500,
      maxXP: 799,
      iconPath: '🥈',
      color: 0xFFC0C0C0,
      glowColor: 0xFFB0B0B0,
    ),
    RankTier(
      id: 'silver_2',
      name: 'Silver II',
      tier: 'Silver',
      division: 2,
      minXP: 800,
      maxXP: 1199,
      iconPath: '🥈',
      color: 0xFFC0C0C0,
      glowColor: 0xFFB0B0B0,
    ),
    RankTier(
      id: 'silver_3',
      name: 'Silver III',
      tier: 'Silver',
      division: 3,
      minXP: 1200,
      maxXP: 1699,
      iconPath: '🥈',
      color: 0xFFC0C0C0,
      glowColor: 0xFFB0B0B0,
    ),
    RankTier(
      id: 'gold_1',
      name: 'Gold I',
      tier: 'Gold',
      division: 1,
      minXP: 1700,
      maxXP: 2299,
      iconPath: '🥇',
      color: 0xFFFFD700,
      glowColor: 0xFFFFC000,
    ),
    RankTier(
      id: 'gold_2',
      name: 'Gold II',
      tier: 'Gold',
      division: 2,
      minXP: 2300,
      maxXP: 2999,
      iconPath: '🥇',
      color: 0xFFFFD700,
      glowColor: 0xFFFFC000,
    ),
    RankTier(
      id: 'gold_3',
      name: 'Gold III',
      tier: 'Gold',
      division: 3,
      minXP: 3000,
      maxXP: 3799,
      iconPath: '🥇',
      color: 0xFFFFD700,
      glowColor: 0xFFFFC000,
    ),
    RankTier(
      id: 'platinum_1',
      name: 'Platinum I',
      tier: 'Platinum',
      division: 1,
      minXP: 3800,
      maxXP: 4699,
      iconPath: '💎',
      color: 0xFFE5E4E2,
      glowColor: 0xFF89CFF0,
    ),
    RankTier(
      id: 'platinum_2',
      name: 'Platinum II',
      tier: 'Platinum',
      division: 2,
      minXP: 4700,
      maxXP: 5699,
      iconPath: '💎',
      color: 0xFFE5E4E2,
      glowColor: 0xFF89CFF0,
    ),
    RankTier(
      id: 'platinum_3',
      name: 'Platinum III',
      tier: 'Platinum',
      division: 3,
      minXP: 5700,
      maxXP: 6799,
      iconPath: '💎',
      color: 0xFFE5E4E2,
      glowColor: 0xFF89CFF0,
    ),
    RankTier(
      id: 'diamond_1',
      name: 'Diamond I',
      tier: 'Diamond',
      division: 1,
      minXP: 6800,
      maxXP: 8099,
      iconPath: '💠',
      color: 0xFFB9F2FF,
      glowColor: 0xFF00BFFF,
    ),
    RankTier(
      id: 'diamond_2',
      name: 'Diamond II',
      tier: 'Diamond',
      division: 2,
      minXP: 8100,
      maxXP: 9499,
      iconPath: '💠',
      color: 0xFFB9F2FF,
      glowColor: 0xFF00BFFF,
    ),
    RankTier(
      id: 'diamond_3',
      name: 'Diamond III',
      tier: 'Diamond',
      division: 3,
      minXP: 9500,
      maxXP: 11099,
      iconPath: '💠',
      color: 0xFFB9F2FF,
      glowColor: 0xFF00BFFF,
    ),
    RankTier(
      id: 'master_1',
      name: 'Master I',
      tier: 'Master',
      division: 1,
      minXP: 11100,
      maxXP: 12999,
      iconPath: '👑',
      color: 0xFF9B30FF,
      glowColor: 0xFF8B00FF,
    ),
    RankTier(
      id: 'master_2',
      name: 'Master II',
      tier: 'Master',
      division: 2,
      minXP: 13000,
      maxXP: 14999,
      iconPath: '👑',
      color: 0xFF9B30FF,
      glowColor: 0xFF8B00FF,
    ),
    RankTier(
      id: 'master_3',
      name: 'Master III',
      tier: 'Master',
      division: 3,
      minXP: 15000,
      maxXP: 17999,
      iconPath: '👑',
      color: 0xFF9B30FF,
      glowColor: 0xFF8B00FF,
    ),
    RankTier(
      id: 'grandmaster',
      name: 'Grandmaster',
      tier: 'Grandmaster',
      division: 0,
      minXP: 18000,
      maxXP: 24999,
      iconPath: '🏆',
      color: 0xFFFF4500,
      glowColor: 0xFFFF6347,
    ),
    RankTier(
      id: 'legend',
      name: 'Legend',
      tier: 'Legend',
      division: 0,
      minXP: 25000,
      maxXP: 999999,
      iconPath: '🌟',
      color: 0xFFFFD700,
      glowColor: 0xFFFFAA00,
      isLegendary: true,
    ),
  ];

  /// Initialize the service
  Future<void> initialize() async {
    if (_box != null) return;
    _box = await Hive.openBox('rank_data');
    debugPrint('🏆 Rank Service initialized');
  }

  /// Get current total XP
  int getTotalXP() {
    if (_box == null) return 0;
    return _box!.get(_totalXPKey, defaultValue: 0);
  }

  /// Get current rank based on XP
  RankTier getCurrentRank() {
    final xp = getTotalXP();
    return getRankForXP(xp);
  }

  /// Get rank for specific XP amount
  RankTier getRankForXP(int xp) {
    for (int i = allRanks.length - 1; i >= 0; i--) {
      if (xp >= allRanks[i].minXP) {
        return allRanks[i];
      }
    }
    return allRanks.first;
  }

  /// Get previous rank (for animation purposes)
  RankTier? getPreviousRank() {
    if (_box == null) return null;
    final previousRankId = _box!.get(_previousRankKey);
    if (previousRankId == null) return null;

    try {
      return allRanks.firstWhere((r) => r.id == previousRankId);
    } catch (_) {
      return null;
    }
  }

  /// Check if there's a pending rank-up animation
  bool hasRankUpPending() {
    if (_box == null) return false;
    return _box!.get(_rankUpPendingKey, defaultValue: false);
  }

  /// Clear the rank-up pending flag (after animation is shown)
  Future<void> clearRankUpPending() async {
    if (_box == null) return;
    await _box!.put(_rankUpPendingKey, false);
  }

  /// Add XP and check for rank up
  /// Returns a RankUpResult if rank changed, null otherwise
  Future<RankUpResult?> addXP(int amount) async {
    if (_box == null) await initialize();
    if (amount <= 0) return null;

    final oldXP = getTotalXP();
    final oldRank = getRankForXP(oldXP);
    final newXP = oldXP + amount;
    final newRank = getRankForXP(newXP);

    // Save new XP
    await _box!.put(_totalXPKey, newXP);
    await _box!.put(_currentRankKey, newRank.id);

    debugPrint('✨ Added $amount XP: $oldXP → $newXP');

    // Check for rank up
    if (newRank.id != oldRank.id) {
      await _box!.put(_previousRankKey, oldRank.id);
      await _box!.put(_rankUpPendingKey, true);

      debugPrint('🎉 RANK UP! ${oldRank.name} → ${newRank.name}');

      return RankUpResult(
        previousRank: oldRank,
        newRank: newRank,
        xpGained: amount,
        totalXP: newXP,
      );
    }

    return null;
  }

  /// Get progress to next rank (0.0 to 1.0)
  double getProgressToNextRank() {
    final xp = getTotalXP();
    final currentRank = getCurrentRank();
    final currentIndex = allRanks.indexWhere((r) => r.id == currentRank.id);

    // Already at max rank
    if (currentIndex >= allRanks.length - 1) {
      return 1.0;
    }

    final nextRank = allRanks[currentIndex + 1];
    final xpInCurrentRank = xp - currentRank.minXP;
    final xpNeededForNextRank = nextRank.minXP - currentRank.minXP;

    return (xpInCurrentRank / xpNeededForNextRank).clamp(0.0, 1.0);
  }

  /// Get XP needed to reach next rank
  int getXPToNextRank() {
    final xp = getTotalXP();
    final currentRank = getCurrentRank();
    final currentIndex = allRanks.indexWhere((r) => r.id == currentRank.id);

    if (currentIndex >= allRanks.length - 1) {
      return 0; // Already max rank
    }

    final nextRank = allRanks[currentIndex + 1];
    return nextRank.minXP - xp;
  }

  /// Get next rank tier
  RankTier? getNextRank() {
    final currentRank = getCurrentRank();
    final currentIndex = allRanks.indexWhere((r) => r.id == currentRank.id);

    if (currentIndex >= allRanks.length - 1) {
      return null; // Already max rank
    }

    return allRanks[currentIndex + 1];
  }

  /// Get rank summary
  Map<String, dynamic> getRankSummary() {
    final currentRank = getCurrentRank();
    final nextRank = getNextRank();

    return {
      'totalXP': getTotalXP(),
      'currentRank': currentRank,
      'nextRank': nextRank,
      'progress': getProgressToNextRank(),
      'xpToNextRank': getXPToNextRank(),
      'hasRankUpPending': hasRankUpPending(),
    };
  }
}

/// Represents a rank tier in the system
class RankTier {
  final String id;
  final String name;
  final String tier;
  final int division;
  final int minXP;
  final int maxXP;
  final String iconPath;
  final int color;
  final int glowColor;
  final bool isLegendary;

  const RankTier({
    required this.id,
    required this.name,
    required this.tier,
    required this.division,
    required this.minXP,
    required this.maxXP,
    required this.iconPath,
    required this.color,
    required this.glowColor,
    this.isLegendary = false,
  });

  /// Get the rank index (position in all ranks)
  int get rankIndex => RankService.allRanks.indexWhere((r) => r.id == id);
}

/// Result of a rank-up event
class RankUpResult {
  final RankTier previousRank;
  final RankTier newRank;
  final int xpGained;
  final int totalXP;

  const RankUpResult({
    required this.previousRank,
    required this.newRank,
    required this.xpGained,
    required this.totalXP,
  });

  /// Check if this is a major tier change (e.g., Silver → Gold)
  bool get isMajorRankUp => previousRank.tier != newRank.tier;
}

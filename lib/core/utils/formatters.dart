// Formatter utilities
class Formatters {
  /// Format score to percentage
  static String formatPercentage(int score, int total) {
    if (total == 0) return '0%';
    return '${(score / total * 100).round()}%';
  }

  /// Format XP with label
  static String formatXP(int xp) => '+$xp XP';

  /// Format coins with label
  static String formatCoins(int coins) => '$coins 🪙';

  /// Format large numbers with K/M suffix
  static String formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  /// Format timer display
  static String formatTimer(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Format streak display
  static String formatStreak(int days) => '$days 🔥';

  /// Format rank tier
  static String formatRank(String tier, int level) => '$tier $level';
}

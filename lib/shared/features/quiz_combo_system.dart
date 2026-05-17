/// Feature 8: Quiz Combo System
/// Consecutive correct answer bonuses
class QuizComboSystem {
  static QuizComboSystem? _instance;

  factory QuizComboSystem() {
    _instance ??= QuizComboSystem._internal();
    return _instance!;
  }

  QuizComboSystem._internal();

  /// Calculate combo multiplier based on consecutive correct answers
  double getComboMultiplier(int comboCount) {
    if (comboCount <= 1) return 1.0;
    if (comboCount <= 3) return 1.2;
    if (comboCount <= 5) return 1.5;
    if (comboCount <= 8) return 1.8;
    if (comboCount <= 10) return 2.0;
    return 2.5; // Max combo
  }

  /// Get combo status message
  String getComboMessage(int comboCount) {
    switch (comboCount) {
      case 2:
        return 'Double! 🔥';
      case 3:
        return 'Triple! 🔥🔥';
      case 5:
        return 'On Fire! 🌟';
      case 8:
        return 'Unstoppable! 💪';
      case 10:
        return 'LEGENDARY! 👑';
      default:
        if (comboCount > 10) return 'GODLIKE! 🌟🌟🌟';
        return '';
    }
  }

  /// Calculate XP with combo bonus
  int calculateComboXP(int baseXP, int comboCount) {
    final multiplier = getComboMultiplier(comboCount);
    return (baseXP * multiplier).round();
  }

  /// Check if combo milestone reached
  bool isMilestone(int comboCount) {
    return [2, 3, 5, 8, 10].contains(comboCount);
  }

  /// Get combo color based on count
  String getComboColor(int comboCount) {
    if (comboCount <= 2) return 'FFB800'; // Gold
    if (comboCount <= 5) return 'FF6B00'; // Orange
    if (comboCount <= 8) return 'FF006E'; // Pink
    return '8B5CF6'; // Purple
  }
}

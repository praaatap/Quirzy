/// Feature 11: Motivational Messages
/// Dynamic encouragement based performance
class MotivationalMessages {
  static const Map<String, dynamic> messages = {
    // Quiz Start Messages
    'quiz_start': [
      '🚀 Ready to learn something amazing?',
      '💪 Let\'s crush this quiz!',
      '🎯 Focus and conquer!',
      '🌟 You\'ve got this!',
      '🧠 Time to show what you know!',
    ],

    // Correct Answer Messages
    'correct': [
      '✅ Nailed it! 🎉',
      '✅ Brilliant! 🌟',
      '✅ You\'re a genius! 🧠',
      '✅ Perfect! Keep going! 🔥',
      '✅ Excellent work! 💪',
      '✅ That\'s the spirit! 🚀',
      '✅ Outstanding! ⭐',
    ],

    // Wrong Answer Messages (encouraging)
    'wrong': [
      '💪 Don\'t worry, learn from this!',
      '📚 Every mistake is a learning opportunity!',
      '🎯 You\'ll get the next one!',
      '💡 Remember this for next time!',
      '🌟 Mistakes make us stronger!',
      '🚀 Keep pushing forward!',
    ],

    // Combo Messages
    'combo': [
      '🔥 COMBO! You\'re unstoppable!',
      '⚡ Lightning streak!',
      '🌟 On fire!',
      '💎 Diamond performance!',
      '👑 Legendary!',
    ],

    // Quiz Complete Messages
    'complete_perfect': [
      '🏆 PERFECT SCORE! You\'re a master!',
      '🌟 100%! Absolutely incredible!',
      '👑 Flawless victory!',
    ],

    'complete_good': [
      '💪 Great job! Keep it up!',
      '⭐ Excellent performance!',
      '🎯 You\'re really improving!',
    ],

    'complete_average': [
      '📚 Good effort! Practice makes perfect!',
      '💪 Solid attempt! Review weak areas!',
      '🎯 You\'re on the right track!',
    ],

    'complete_poor': [
      '🌟 Don\'t give up! Every expert was once a beginner!',
      '💪 Keep practicing! You\'ll get there!',
      '📚 Review the material and try again!',
    ],

    // Streak Messages
    'streak_1': '🌱 Day 1! The journey begins!',
    'streak_3': '🔥 3 days! Building momentum!',
    'streak_7': '⭐ Week warrior! Amazing!',
    'streak_14': '🏆 2 weeks! Incredible dedication!',
    'streak_30': '👑 Monthly Master! You inspire us!',
    'streak_100': '🌟🌟🌟 LEGENDARY! Century Club!',

    // Time-based Greetings
    'morning': '☀️ Good morning! Ready to learn?',
    'afternoon': '🌞 Afternoon study session! Let\'s go!',
    'evening': '🌙 Evening learning! Great dedication!',
    'night': '🦉 Night owl mode! Keep it up!',
  };

  /// Get random message from category
  static String getMessage(String category) {
    final categoryMessages = messages[category] as List<String>?;
    if (categoryMessages == null || categoryMessages.isEmpty) {
      return '🌟 Keep learning!';
    }
    return categoryMessages[DateTime.now().millisecond % categoryMessages.length];
  }

  /// Get message based on quiz performance
  static String getQuizCompleteMessage(int percentage) {
    if (percentage == 100) {
      return getMessage('complete_perfect');
    } else if (percentage >= 70) {
      return getMessage('complete_good');
    } else if (percentage >= 50) {
      return getMessage('complete_average');
    } else {
      return getMessage('complete_poor');
    }
  }

  /// Get time-based greeting
  static String getTimeGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 6) return messages['night'] as String;
    if (hour < 12) return messages['morning'] as String;
    if (hour < 17) return messages['afternoon'] as String;
    if (hour < 21) return messages['evening'] as String;
    return messages['night'] as String;
  }

  /// Get streak message
  static String getStreakMessage(int streak) {
    if (streak >= 100) return messages['streak_100'] as String;
    if (streak >= 30) return messages['streak_30'] as String;
    if (streak >= 14) return messages['streak_14'] as String;
    if (streak >= 7) return messages['streak_7'] as String;
    if (streak >= 3) return messages['streak_3'] as String;
    if (streak >= 1) return messages['streak_1'] as String;
    return '📚 Start your streak today!';
  }
}

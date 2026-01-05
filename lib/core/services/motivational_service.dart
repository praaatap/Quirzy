import 'dart:math';

/// Motivational Quotes Service - Works completely offline
/// Provides daily motivation and learning tips
class MotivationalService {
  static final MotivationalService _instance = MotivationalService._internal();
  factory MotivationalService() => _instance;
  MotivationalService._internal();

  final Random _random = Random();

  // Learning-focused motivational quotes
  static const List<Map<String, String>> learningQuotes = [
    {
      'quote':
          'The beautiful thing about learning is that no one can take it away from you.',
      'author': 'B.B. King',
    },
    {
      'quote':
          'Education is not the filling of a pail, but the lighting of a fire.',
      'author': 'W.B. Yeats',
    },
    {
      'quote': 'The more that you read, the more things you will know.',
      'author': 'Dr. Seuss',
    },
    {
      'quote':
          'Live as if you were to die tomorrow. Learn as if you were to live forever.',
      'author': 'Mahatma Gandhi',
    },
    {
      'quote': 'The expert in anything was once a beginner.',
      'author': 'Helen Hayes',
    },
    {
      'quote': 'Learning never exhausts the mind.',
      'author': 'Leonardo da Vinci',
    },
    {
      'quote': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
    },
    {
      'quote':
          'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill',
    },
    {
      'quote': 'The journey of a thousand miles begins with one step.',
      'author': 'Lao Tzu',
    },
    {'quote': 'Knowledge is power.', 'author': 'Francis Bacon'},
    {
      'quote': 'The mind is everything. What you think you become.',
      'author': 'Buddha',
    },
    {
      'quote': 'Education is the passport to the future.',
      'author': 'Malcolm X',
    },
    {
      'quote': 'An investment in knowledge pays the best interest.',
      'author': 'Benjamin Franklin',
    },
    {
      'quote': 'The roots of education are bitter, but the fruit is sweet.',
      'author': 'Aristotle',
    },
    {
      'quote':
          'Tell me and I forget. Teach me and I remember. Involve me and I learn.',
      'author': 'Benjamin Franklin',
    },
    {
      'quote':
          'The capacity to learn is a gift; the ability to learn is a skill; the willingness to learn is a choice.',
      'author': 'Brian Herbert',
    },
    {
      'quote': 'Learning is a treasure that will follow its owner everywhere.',
      'author': 'Chinese Proverb',
    },
    {
      'quote':
          'The only person who is educated is the one who has learned how to learn and change.',
      'author': 'Carl Rogers',
    },
    {
      'quote':
          'Develop a passion for learning. If you do, you will never cease to grow.',
      'author': 'Anthony J. D\'Angelo',
    },
    {
      'quote': 'Anyone who stops learning is old, whether at twenty or eighty.',
      'author': 'Henry Ford',
    },
  ];

  // Study tips
  static const List<String> studyTips = [
    '💡 Break your study sessions into 25-minute focused blocks with 5-minute breaks (Pomodoro Technique).',
    '📝 Write things down by hand - it helps memory retention by 40%.',
    '🧠 Test yourself regularly - active recall is more effective than re-reading.',
    '😴 Get enough sleep - your brain consolidates learning while you rest.',
    '🎯 Set specific, achievable goals for each study session.',
    '📚 Teach what you learn to someone else - it deepens understanding.',
    '🔄 Use spaced repetition - review material at increasing intervals.',
    '🎧 Try studying with instrumental music if you need focus.',
    '💪 Exercise regularly - it improves memory and cognitive function.',
    '📱 Put your phone in another room while studying to avoid distractions.',
    '🌅 Morning study sessions often provide better focus and retention.',
    '✍️ Create mind maps to visualize connections between concepts.',
    '🎲 Mix up your subjects - interleaving improves long-term retention.',
    '❓ Form questions about the material before reading it.',
    '🗣️ Read important concepts out loud to engage multiple senses.',
    '📊 Use the 80/20 rule - focus on the 20% that gives 80% of results.',
    '🎨 Use colors and visuals to make notes more memorable.',
    '⏰ Study your hardest subjects when your energy is highest.',
    '🍎 Stay hydrated and eat brain-boosting foods like nuts and berries.',
    '🏃 Take a short walk before studying to boost alertness.',
  ];

  // Streak encouragements
  static const List<String> streakMessages = [
    '🔥 Amazing! Keep that streak going!',
    '⭐ You\'re on fire! Don\'t break the chain!',
    '🏆 Champions show up every day!',
    '💪 Consistency beats intensity!',
    '🚀 You\'re building an unstoppable habit!',
    '🎯 One day at a time, you\'re crushing it!',
    '✨ Your dedication is inspiring!',
    '📈 Every day you\'re getting stronger!',
    '🌟 Streak warriors never quit!',
    '💎 Diamonds are made under pressure. Keep going!',
  ];

  // Performance messages
  static const Map<String, List<String>> performanceMessages = {
    'perfect': [
      '🎯 PERFECT SCORE! You\'re absolutely brilliant!',
      '💯 Flawless! Nothing can stop you!',
      '👑 A perfect performance! You\'re a genius!',
      '🌟 100%! You\'ve mastered this topic!',
    ],
    'excellent': [
      '🔥 Excellent work! Almost perfect!',
      '⭐ Outstanding performance!',
      '🏆 You\'re crushing it!',
      '💪 Brilliant! Keep this momentum!',
    ],
    'good': [
      '👍 Good job! You\'re making progress!',
      '📈 Nice work! Room to grow!',
      '✨ Well done! Keep pushing!',
      '🎯 Solid performance! Keep learning!',
    ],
    'needsWork': [
      '💪 Don\'t give up! Practice makes perfect!',
      '📚 Keep studying, you\'ll get there!',
      '🌱 Every expert was once a beginner!',
      '🔄 Try again - you\'re learning with each attempt!',
    ],
  };

  /// Get quote of the day (deterministic based on date)
  Map<String, String> getQuoteOfTheDay() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % learningQuotes.length;
    return learningQuotes[index];
  }

  /// Get a random quote
  Map<String, String> getRandomQuote() {
    return learningQuotes[_random.nextInt(learningQuotes.length)];
  }

  /// Get study tip of the day
  String getStudyTipOfTheDay() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % studyTips.length;
    return studyTips[index];
  }

  /// Get a random study tip
  String getRandomStudyTip() {
    return studyTips[_random.nextInt(studyTips.length)];
  }

  /// Get streak encouragement message
  String getStreakMessage(int streakDays) {
    if (streakDays <= 0) {
      return '🌅 Start your streak today! Complete a quiz to begin.';
    }
    if (streakDays == 1) {
      return '🌱 Day 1! The beginning of something great!';
    }
    if (streakDays < 7) {
      return '${streakMessages[_random.nextInt(streakMessages.length)]} $streakDays days!';
    }
    if (streakDays == 7) {
      return '🎉 ONE WEEK STREAK! You\'re unstoppable!';
    }
    if (streakDays < 30) {
      return '🔥 $streakDays day streak! You\'re a learning machine!';
    }
    if (streakDays == 30) {
      return '🏆 30 DAY STREAK! You\'re a legend!';
    }
    return '👑 $streakDays DAY STREAK! You\'re in the hall of fame!';
  }

  /// Get performance message based on score percentage
  String getPerformanceMessage(double percentage) {
    List<String> messages;
    if (percentage >= 100) {
      messages = performanceMessages['perfect']!;
    } else if (percentage >= 80) {
      messages = performanceMessages['excellent']!;
    } else if (percentage >= 60) {
      messages = performanceMessages['good']!;
    } else {
      messages = performanceMessages['needsWork']!;
    }
    return messages[_random.nextInt(messages.length)];
  }

  /// Get welcome message based on time of day
  String getWelcomeMessage() {
    final hour = DateTime.now().hour;
    if (hour < 6) {
      return '🌙 Burning the midnight oil? Let\'s learn!';
    } else if (hour < 12) {
      return '☀️ Good morning! Ready to learn something new?';
    } else if (hour < 17) {
      return '🌤️ Good afternoon! Time for a brain boost!';
    } else if (hour < 21) {
      return '🌆 Good evening! Let\'s close the day with learning!';
    } else {
      return '🌙 Night owl mode! Perfect time for quiet studying.';
    }
  }

  /// Get all quotes for display
  List<Map<String, String>> getAllQuotes() {
    return learningQuotes;
  }

  /// Get all study tips for display
  List<String> getAllStudyTips() {
    return studyTips;
  }
}

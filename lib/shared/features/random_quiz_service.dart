import 'dart:math';

/// Feature 2: Random Quiz Generator
/// "Surprise me" mode - generates quiz on random topics
class RandomQuizService {
  static RandomQuizService? _instance;
  final Random _random = Random();

  factory RandomQuizService() {
    _instance ??= RandomQuizService._internal();
    return _instance!;
  }

  RandomQuizService._internal();

  /// Get random topic from predefined list
  String getRandomTopic() {
    final topics = [
      'Science', 'History', 'Geography', 'Mathematics',
      'Technology', 'Literature', 'Sports', 'Entertainment',
      'Art', 'Music', 'Philosophy', 'Economics',
      'Biology', 'Physics', 'Chemistry', 'Politics',
    ];
    return topics[_random.nextInt(topics.length)];
  }

  /// Get random difficulty
  String getRandomDifficulty() {
    final difficulties = ['Easy', 'Medium', 'Hard'];
    return difficulties[_random.nextInt(difficulties.length)];
  }

  /// Generate random quiz config
  Map<String, dynamic> generateRandomQuizConfig() {
    return {
      'topic': getRandomTopic(),
      'difficulty': getRandomDifficulty(),
      'questionCount': [5, 10, 15, 20][_random.nextInt(4)],
      'surprise': true,
    };
  }

  /// Get fun motivational message for random quiz
  String getRandomMotivation() {
    final messages = [
      '🎲 Let fate guide your learning!',
      '🎰 Spin the wheel of knowledge!',
      '🌟 Ready for a surprise challenge?',
      '🎯 Testing random topics makes you a polymath!',
      '🧠 Broaden your horizons!',
      '🚀 Adventure awaits!',
    ];
    return messages[_random.nextInt(messages.length)];
  }
}

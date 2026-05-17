/// Feature 9: Smart Hints Service
/// Context-aware help during quizzes
class SmartHintsService {
  static SmartHintsService? _instance;

  factory SmartHintsService() {
    _instance ??= SmartHintsService._internal();
    return _instance!;
  }

  SmartHintsService._internal();

  /// Generate hint based on question context
  String generateHint({
    required String question,
    required List<String> options,
    required int currentStreak,
    required bool isFirstAttempt,
  }) {
    // Different hint types based on context
    if (!isFirstAttempt) {
      return _getSecondAttemptHint(options);
    }

    if (currentStreak >= 5) {
      return '🔥 You\'re on fire! Trust your instincts!';
    }

    return _getContextualHint(question, options);
  }

  String _getContextualHint(String question, List<String> options) {
    final questionLower = question.toLowerCase();
    
    // Date/Year questions
    if (questionLower.contains('year') || questionLower.contains('when')) {
      return '💡 Look for chronological clues in the question';
    }
    
    // Definition questions
    if (questionLower.contains('what is') || questionLower.contains('define')) {
      return '💡 Think about the key terms in the definition';
    }
    
    // Math questions
    if (questionLower.contains('calculate') || RegExp(r'\d+\s*[+\-*/]').hasMatch(question)) {
      return '💡 Try eliminating obviously wrong answers first';
    }

    // Default hints
    final hints = [
      '💡 Read all options carefully',
      '💡 Look for keywords in the question',
      '💡 Eliminate obviously wrong answers',
      '💡 Think about what you learned recently',
    ];
    
    return hints[DateTime.now().millisecond % hints.length];
  }

  String _getSecondAttemptHint(List<String> options) {
    final hints = [
      '💡 Try a different approach this time',
      '💡 Review the question carefully',
      '💡 Consider each option systematically',
    ];
    return hints[DateTime.now().millisecond % hints.length];
  }

  /// Get hint usage limit (3 per quiz)
  int getMaxHints() => 3;
}

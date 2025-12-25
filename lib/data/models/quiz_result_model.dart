// ============================================================================
// QUIRZY - PROPRIETARY AND CONFIDENTIAL
// ============================================================================
// Copyright (c) 2025 Quirzy. All Rights Reserved.
//
// This source code is licensed under the Quirzy Proprietary License.
// See the LICENSE file in the root directory for full terms.
//
// UNAUTHORIZED COPYING, MODIFICATION, DISTRIBUTION, OR USE IS STRICTLY
// PROHIBITED. This code is provided for VIEWING PURPOSES ONLY.
// ============================================================================

/// Quiz result model representing a completed quiz attempt
class QuizResultModel {
  final String id;
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> questions;
  final List<int> userSelectedAnswers;
  final int timeTaken;
  final DateTime? completedAt;

  const QuizResultModel({
    required this.id,
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.questions,
    required this.userSelectedAnswers,
    this.timeTaken = 0,
    this.completedAt,
  });

  /// Create from JSON response
  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id']?.toString() ?? '',
      quizId: json['quizId']?.toString() ?? '',
      quizTitle: json['quizTitle'] as String? ?? 'Untitled Quiz',
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      questions: List<Map<String, dynamic>>.from(
        json['questions'] ?? json['questionsJson'] ?? [],
      ),
      userSelectedAnswers: List<int>.from(
        json['userSelectedAnswers'] ?? json['userAnswersJson'] ?? [],
      ),
      timeTaken: json['timeTaken'] as int? ?? 0,
      completedAt: json['completedAt'] != null || json['createdAt'] != null
          ? DateTime.tryParse(
              (json['completedAt'] ?? json['createdAt']).toString(),
            )
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'questions': questions,
      'userSelectedAnswers': userSelectedAnswers,
      'timeTaken': timeTaken,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Calculate percentage score
  double get percentage =>
      totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  /// Get formatted time
  String get formattedTime {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }

  /// Create a copy with updated fields
  QuizResultModel copyWith({
    String? id,
    String? quizId,
    String? quizTitle,
    int? score,
    int? totalQuestions,
    List<Map<String, dynamic>>? questions,
    List<int>? userSelectedAnswers,
    int? timeTaken,
    DateTime? completedAt,
  }) {
    return QuizResultModel(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      quizTitle: quizTitle ?? this.quizTitle,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questions: questions ?? this.questions,
      userSelectedAnswers: userSelectedAnswers ?? this.userSelectedAnswers,
      timeTaken: timeTaken ?? this.timeTaken,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

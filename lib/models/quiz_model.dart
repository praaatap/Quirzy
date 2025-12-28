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

/// Quiz model representing a quiz entity
class QuizModel {
  final String id;
  final String title;
  final String topic;
  final String difficulty;
  final int questionCount;
  final List<QuestionModel> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QuizModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.questionCount,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  /// Create QuizModel from JSON response
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final questionsJson = json['questions'] as List<dynamic>? ?? [];

    return QuizModel(
      id: json['id']?.toString() ?? json['quizId']?.toString() ?? '',
      title:
          json['title'] as String? ??
          json['topic'] as String? ??
          'Untitled Quiz',
      topic: json['topic'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'medium',
      questionCount: json['questionCount'] as int? ?? questionsJson.length,
      questions: questionsJson
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  /// Convert QuizModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  QuizModel copyWith({
    String? id,
    String? title,
    String? topic,
    String? difficulty,
    int? questionCount,
    List<QuestionModel>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Question model representing a single quiz question
class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  /// Create QuestionModel from JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] as int? ?? 0,
      explanation: json['explanation'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
    };
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StudyService {
  static final StudyService _instance = StudyService._internal();
  factory StudyService() => _instance;
  StudyService._internal();

  // Replace with your actual backend URL or use standard localhosts
  // For Android Emulator: 10.0.2.2
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  Box? _historyBox;

  Future<void> initialize() async {
    if (_historyBox == null) {
      if (!Hive.isBoxOpen('study_history')) {
        _historyBox = await Hive.openBox('study_history');
      } else {
        _historyBox = Hive.box('study_history');
      }
    }
  }

  Future<StudySet> generateStudySet(String text) async {
    await initialize(); // Ensure box is open

    // 1. Check if we have this exact text cached (Simple caching optimization)
    // We use a simple hash or just check recent entries to avoid expensive re-gen
    final cacheKey = text.hashCode.toString();
    if (_historyBox!.containsKey(cacheKey)) {
      debugPrint('⚡ Cache Hit! Loading study set from local storage.');
      try {
        final cachedJson = jsonDecode(_historyBox!.get(cacheKey));
        return StudySet.fromJson(cachedJson);
      } catch (e) {
        debugPrint('⚠️ Cache corrupted, regenerating...');
      }
    }

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) throw Exception('User not authenticated');

      debugPrint(
        '🧠 Requesting study generation for text (${text.length} chars)...',
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/study/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'text': text}),
      );

      if (response.statusCode == 200) {
        // Use compute to parse large JSON in background isolate
        // This offloads the heavy work from the main thread
        final studySet = await compute(_parseStudySet, response.body);

        // 2. Save to history automatically (re-serialize for storage)
        await _saveToHistory(cacheKey, text, studySet.toJson());

        return studySet;
      } else {
        throw Exception('Failed to generate study set: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Study Generation Error: $e');
      rethrow;
    }
  }

  Future<void> _saveToHistory(
    String key,
    String originalText,
    Map<String, dynamic> jsonData,
  ) async {
    // Add metadata for display in list
    jsonData['createdAt'] = DateTime.now().toIso8601String();
    jsonData['previewText'] = originalText.substring(
      0,
      originalText.length > 80 ? 80 : originalText.length,
    );

    await _historyBox!.put(key, jsonEncode(jsonData));
  }

  List<StudySet> getHistory() {
    if (_historyBox == null) return [];

    final List<StudySet> history = [];
    for (var i = 0; i < _historyBox!.length; i++) {
      try {
        final jsonStr = _historyBox!.getAt(i) as String;
        history.add(StudySet.fromJson(jsonDecode(jsonStr)));
      } catch (e) {
        // Skip corrupted entries
      }
    }
    // Return newest first
    return history.reversed.toList();
  }

  Future<void> clearHistory() async {
    await _historyBox?.clear();
  }

  // Static function for compute isolate
  static StudySet _parseStudySet(String responseBody) {
    final data = jsonDecode(responseBody);
    return StudySet.fromJson(data);
  }
}

class StudySet {
  final String summary;
  final List<PodcastLine> podcastScript;
  final List<FlashcardData> flashcards;
  final List<QuizQuestionData> quiz;
  final DateTime? createdAt; // New field
  final String? previewText; // New field

  StudySet({
    required this.summary,
    required this.podcastScript,
    required this.flashcards,
    required this.quiz,
    this.createdAt,
    this.previewText,
  });

  factory StudySet.fromJson(Map<String, dynamic> json) {
    return StudySet(
      summary: json['summary'] as String? ?? 'No summary available.',
      podcastScript:
          (json['podcastScript'] as List?)
              ?.map((e) => PodcastLine.fromJson(e))
              .toList() ??
          [],
      flashcards:
          (json['flashcards'] as List?)
              ?.map((e) => FlashcardData.fromJson(e))
              .toList() ??
          [],
      quiz:
          (json['quiz'] as List?)
              ?.map((e) => QuizQuestionData.fromJson(e))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      previewText: json['previewText'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'summary': summary,
    'podcastScript': podcastScript.map((e) => e.toJson()).toList(),
    'flashcards': flashcards.map((e) => e.toJson()).toList(),
    'quiz': quiz.map((e) => e.toJson()).toList(),
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (previewText != null) 'previewText': previewText,
  };
}

class PodcastLine {
  final String speaker;
  final String text;

  PodcastLine({required this.speaker, required this.text});

  factory PodcastLine.fromJson(Map<String, dynamic> json) {
    return PodcastLine(
      speaker: json['speaker'] as String? ?? 'Host',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'speaker': speaker, 'text': text};
}

class FlashcardData {
  final String front;
  final String back;

  FlashcardData({required this.front, required this.back});

  factory FlashcardData.fromJson(Map<String, dynamic> json) {
    return FlashcardData(
      front: json['front'] as String? ?? '',
      back: json['back'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'front': front, 'back': back};
}

class QuizQuestionData {
  final String questionText;
  final List<String> options;
  final int correctAnswer;

  QuizQuestionData({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestionData.fromJson(Map<String, dynamic> json) {
    return QuizQuestionData(
      questionText: json['questionText'] as String? ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'questionText': questionText,
    'options': options,
    'correctAnswer': correctAnswer,
  };
}

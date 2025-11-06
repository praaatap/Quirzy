import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:quirzy/utils/constant.dart';

class AIProvider {
  late final GenerativeModel _model;
  bool _isInitialized = false;

  AIProvider(String apiKey) {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.5, // Balanced creativity
          topP: 0.9,
          topK: 40,
          maxOutputTokens: 4000, // Increased for longer quizzes
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.medium,
          ),
        ],
      );
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AI model: $e');
    }
  }

  Future<Map<String, dynamic>> generateQuiz(String topic) async {
    if (!_isInitialized) {
      return _errorResponse('AI model not initialized');
    }

    try {
      final prompt =
          '''
    Generate a high-quality quiz about "$topic" with EXACTLY this JSON structure:

    {
      "title": "Creative Quiz Title About $topic",
      "questions": [
        {
          "questionText": "Clear, specific question?",
          "options": [
            "Plausible option 1",
            "Plausible option 2", 
            "Plausible option 3",
            "Plausible option 4"
          ],
          "correctAnswer": 0, // Index of correct option (0-3)
          "explanation": "Brief explanation of correct answer" // Optional
        }
      ]
    }

    REQUIREMENTS:
    - 10 diverse questions covering different aspects of $topic
    - Each question must have exactly 4 options
    - correctAnswer must be 0, 1, 2, or 3
    - Questions should progress from easy to medium difficulty
    - Avoid trivial/obvious questions
    - Return ONLY valid JSON (no markdown, no extra text)
    - Ensure JSON is syntactically perfect for direct parsing

    EXAMPLE FOR TOPIC "Space":
    {
      "title": "Space Exploration Quiz",
      "questions": [
        {
          "questionText": "Which planet has the most moons?",
          "options": ["Mars", "Saturn", "Venus", "Mercury"],
          "correctAnswer": 1,
          "explanation": "Saturn has over 80 moons, the most in our solar system"
        }
      ]
    }
    ''';

      final content = Content.text(prompt); // Create Content object from prompt
      final response = await _model.generateContent([content]);

      if (response.text == null || response.text!.isEmpty) {
        return _errorResponse('Empty response from AI model');
      }

      return _parseAndValidateResponse(response.text!);
    } catch (e) {
      debugPrint('Quiz generation error: $e');
      return _errorResponse('Failed to generate quiz: ${e.toString()}');
    }
  }

  Map<String, dynamic> _errorResponse(String error) {
    debugPrint('Quiz Error: $error');
    return {'error': error, 'questions': [], 'title': 'Quiz Generation Failed'};
  }

  Map<String, dynamic> _parseAndValidateResponse(String rawResponse) {
    try {
      // Clean the response
      String jsonString = rawResponse
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse JSON
      final result = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate structure
      if (result['title'] == null || result['questions'] == null) {
        throw FormatException('Missing required fields (title/questions)');
      }

      final questions = result['questions'] as List;
      if (questions.isEmpty || questions.length != 10) {
        throw FormatException('Expected exactly 10 questions');
      }

      // Validate each question
      for (final q in questions.cast<Map<String, dynamic>>()) {
        if (q['questionText'] == null ||
            q['options'] == null ||
            q['correctAnswer'] == null) {
          throw FormatException('Question missing required fields');
        }

        final options = q['options'] as List;
        if (options.length != 4) {
          throw FormatException('Each question must have 4 options');
        }

        final correctIndex = q['correctAnswer'] as int;
        if (correctIndex < 0 || correctIndex > 3) {
          throw FormatException('correctAnswer must be between 0-3');
        }
      }

      return result;
    } catch (e) {
      debugPrint('Response parsing error: $e\nRaw response: $rawResponse');
      rethrow;
    }
  }
}

final aiProvider = Provider<AIProvider>((ref) {
  const apiKey = kgeminiKey;
  return AIProvider(apiKey);
});

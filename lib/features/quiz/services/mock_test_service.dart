import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'services.dart';

class MockTestSection {
  final String name;
  final int questionCount;
  final int startIndex;
  int score;
  int attempted;
  int correct;

  MockTestSection({
    required this.name,
    required this.questionCount,
    required this.startIndex,
    this.score = 0,
    this.attempted = 0,
    this.correct = 0,
  });

  double get accuracy => attempted > 0 ? (correct / attempted * 100) : 0;
}

class MockTestData {
  final String mockTestId;
  final String title;
  final String examType;
  final int totalQuestions;
  final int durationMinutes;
  final List<MockTestSection> sections;
  final List<Map<String, dynamic>> questions;

  const MockTestData({
    required this.mockTestId,
    required this.title,
    required this.examType,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.sections,
    required this.questions,
  });
}

/// Exam configurations mirroring the Appwrite function
const Map<String, Map<String, dynamic>> examConfigs = {
  'JEE': {'duration': 180, 'label': 'JEE Mains/Advanced'},
  'NEET': {'duration': 200, 'label': 'NEET UG'},
  'CAT': {'duration': 120, 'label': 'CAT MBA'},
  'CUET': {'duration': 120, 'label': 'CUET UG'},
  'MBA': {'duration': 105, 'label': 'MBA Entrance'},
  'GRE': {'duration': 230, 'label': 'GRE'},
  'IELTS': {'duration': 60, 'label': 'IELTS'},
  'GMAT': {'duration': 187, 'label': 'GMAT'},
  'General': {'duration': 60, 'label': 'General Knowledge'},
};

class MockTestService {
  final Functions _fn = AppwriteClient.instance.functions;
  final Account _account = AppwriteClient.instance.account;
  final Databases _db = AppwriteClient.instance.databases;

  Future<MockTestData> generateMockTest({required String examType}) async {
    final user = await _account.get();

    final execution = await _fn.createExecution(
      functionId: AppwriteConfig.mockTestFunction,
      body: jsonEncode({'examType': examType, 'userId': user.$id}),
    );

    if (execution.status.name != 'completed') {
      throw Exception('Mock test generation failed');
    }

    final response = jsonDecode(execution.responseBody) as Map<String, dynamic>;
    if (response['error'] != null) throw Exception(response['error']);

    final sectionsRaw = (response['sections'] as List<dynamic>? ?? []);
    final sections = sectionsRaw.map((s) => MockTestSection(
      name: s['name'] as String,
      questionCount: s['questionCount'] as int,
      startIndex: s['startIndex'] as int,
    )).toList();

    return MockTestData(
      mockTestId: response['mockTestId'] as String,
      title: response['title'] as String,
      examType: response['examType'] as String,
      totalQuestions: response['totalQuestions'] as int,
      durationMinutes: response['durationMinutes'] as int,
      sections: sections,
      questions: List<Map<String, dynamic>>.from(response['questions'] ?? []),
    );
  }

  Future<void> saveMockTestResult({
    required String mockTestId,
    required int score,
    required int totalQuestions,
    required int timeTakenSeconds,
    required List<MockTestSection> sections,
  }) async {
    final percentage = totalQuestions > 0 ? (score / totalQuestions * 100) : 0.0;
    final sectionsResultData = sections.map((s) => {
      'name': s.name,
      'score': s.correct,
      'attempted': s.attempted,
      'accuracy': s.accuracy,
    }).toList();

    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.mockTestsCollection,
      documentId: mockTestId,
      data: {
        'status': 'completed',
        'score': score,
        'percentage': percentage,
        'timeTakenSeconds': timeTakenSeconds,
        'sectionsResult': jsonEncode(sectionsResultData),
        'completedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getMockTestHistory() async {
    try {
      final user = await _account.get();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.mockTestsCollection,
        queries: [
          Query.equal('userId', user.$id),
          Query.equal('status', 'completed'),
          Query.orderDesc('completedAt'),
          Query.limit(10),
        ],
      );
      return result.documents.map((d) => d.data).toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> getExamConfig(String examType) {
    return examConfigs[examType] ?? examConfigs['General']!;
  }

  List<String> get availableExams => examConfigs.keys.toList();
}

import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'services.dart';

/// Service for user-vs-user quiz challenges via Appwrite Function
class ChallengeService {
  final Functions _fn = AppwriteClient.instance.functions;
  final Account _account = AppwriteClient.instance.account;

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final execution = await _fn.createExecution(
      functionId: AppwriteConfig.challengeManageFunction,
      body: jsonEncode(body),
    );

    if (execution.status.name == 'completed') {
      final response = jsonDecode(execution.responseBody) as Map<String, dynamic>;
      if (response['error'] != null) throw Exception(response['error']);
      return response;
    }
    throw Exception('Challenge operation failed');
  }

  Future<Map<String, dynamic>> sendChallenge({
    required String opponentId,
    String? quizId,
  }) async {
    final user = await _account.get();
    return _call({
      'action': 'send',
      'challengerId': user.$id,
      'opponentId': opponentId,
      if (quizId != null) 'quizId': quizId,
    });
  }

  Future<Map<String, dynamic>> acceptChallenge(String challengeId) async {
    return _call({'action': 'accept', 'challengeId': challengeId});
  }

  Future<Map<String, dynamic>> rejectChallenge(String challengeId) async {
    return _call({'action': 'reject', 'challengeId': challengeId});
  }

  Future<Map<String, dynamic>> cancelChallenge(String challengeId) async {
    return _call({'action': 'cancel', 'challengeId': challengeId});
  }

  Future<Map<String, dynamic>> getMyChallenges() async {
    final user = await _account.get();
    return _call({'action': 'getMyChallenges', 'userId': user.$id});
  }

  Future<Map<String, dynamic>> getChallengeStatus(String challengeId) async {
    return _call({'action': 'getStatus', 'challengeId': challengeId});
  }
}

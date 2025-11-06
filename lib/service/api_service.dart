import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/utils/constant.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();

  // ==================== AUTHENTICATION ====================

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      debugPrint('❌ Get token error: $e');
      return null;
    }
  }

  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'token', value: token);
      debugPrint('✅ Token saved successfully');
    } catch (e) {
      debugPrint('❌ Save token error: $e');
      rethrow;
    }
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'token');
      debugPrint('✅ Token deleted successfully');
    } catch (e) {
      debugPrint('❌ Delete token error: $e');
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Search users by name or email
  static Future<Map<String, dynamic>> searchUsers(String query) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('🔍 Searching users with query: $query');
      
      final uri = Uri.parse('${kBackendApiUrl}/search-users?q=${Uri.encodeComponent(query)}');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Search API Status: ${response.statusCode}');
      debugPrint('Search API Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Invalid search query');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to search users');
      }
    } catch (e) {
      debugPrint('❌ Search users error: $e');
      rethrow;
    }
  }

  /// Get all users (for testing/admin)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      final uri = Uri.parse('${kBackendApiUrl}/users');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to get users');
      }
    } catch (e) {
      debugPrint('❌ Get all users error: $e');
      rethrow;
    }
  }

  // ==================== CHALLENGE MANAGEMENT ====================

  /// Send a challenge to another user
  static Future<Map<String, dynamic>> sendChallenge({
    required int opponentId,
    int? quizId,
  }) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('📤 Sending challenge to opponent ID: $opponentId');

      final uri = Uri.parse('${kBackendApiUrl}/challenge/send');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'opponentId': opponentId,
          if (quizId != null) 'quizId': quizId,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Send Challenge Status: ${response.statusCode}');
      debugPrint('Send Challenge Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Opponent not found');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to send challenge');
      }
    } catch (e) {
      debugPrint('❌ Send challenge error: $e');
      rethrow;
    }
  }

  /// Get challenge status by ID
  static Future<Map<String, dynamic>> getChallengeStatus(int challengeId) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('📊 Getting challenge status for ID: $challengeId');

      final uri = Uri.parse('${kBackendApiUrl}/challenge/$challengeId');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Get Challenge Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Challenge not found');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to get challenge status');
      }
    } catch (e) {
      debugPrint('❌ Get challenge status error: $e');
      rethrow;
    }
  }

  /// Accept a challenge
  static Future<Map<String, dynamic>> acceptChallenge(int challengeId) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('✅ Accepting challenge ID: $challengeId');

      final uri = Uri.parse('${kBackendApiUrl}/challenge/$challengeId/accept');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Accept Challenge Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Challenge not found or already accepted');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Challenge has expired');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to accept challenge');
      }
    } catch (e) {
      debugPrint('❌ Accept challenge error: $e');
      rethrow;
    }
  }

  /// Reject a challenge
  static Future<Map<String, dynamic>> rejectChallenge(int challengeId) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('❌ Rejecting challenge ID: $challengeId');

      final uri = Uri.parse('${kBackendApiUrl}/challenge/$challengeId/reject');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Reject Challenge Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Challenge not found');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to reject challenge');
      }
    } catch (e) {
      debugPrint('❌ Reject challenge error: $e');
      rethrow;
    }
  }

  /// Cancel a challenge (for challenger only)
  static Future<void> cancelChallenge(int challengeId) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('🚫 Cancelling challenge ID: $challengeId');

      final uri = Uri.parse('${kBackendApiUrl}/challenge/$challengeId');
      
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Cancel Challenge Status: ${response.statusCode}');
      debugPrint('Cancel Challenge Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Challenge cancelled successfully');
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Challenge not found or cannot be cancelled');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to cancel challenge');
      }
    } catch (e) {
      debugPrint('❌ Cancel challenge error: $e');
      rethrow;
    }
  }

  /// Get all challenges for current user
  static Future<List<Map<String, dynamic>>> getMyChallenges() async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('📋 Getting my challenges');

      final uri = Uri.parse('${kBackendApiUrl}/challenges/my');
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint('Get My Challenges Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['challenges']);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to get challenges');
      }
    } catch (e) {
      debugPrint('❌ Get my challenges error: $e');
      rethrow;
    }
  }

  // ==================== FCM TOKEN MANAGEMENT ====================

  /// Save FCM token for push notifications
  static Future<void> saveFCMToken(String fcmToken) async {
    try {
      final token = await getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      debugPrint('💾 Saving FCM token');

      final uri = Uri.parse('${kBackendApiUrl}/auth/save-token');
      
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fcmToken': fcmToken,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Save FCM Token Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token saved successfully');
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to save FCM token');
      }
    } catch (e) {
      debugPrint('❌ Save FCM token error: $e');
      rethrow;
    }
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Reset password
  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔑 Resetting password for: $email');

      final uri = Uri.parse('${kBackendApiUrl}/reset-password');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      debugPrint('Reset Password Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Password reset successfully');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['error'] ?? 'Failed to reset password');
      }
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data
  static Future<void> clearAllData() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ All data cleared');
    } catch (e) {
      debugPrint('❌ Clear data error: $e');
    }
  }


  static Future<void> saveFcmToken(String fcmToken, String authToken) async {
    debugPrint('📤 API: Saving FCM token');

    final response = await http.post(
      Uri.parse('${kBackendApiUrl}/auth/save-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode == 200) {
      debugPrint('✅ API: FCM token saved successfully');
    } else {
      final data = jsonDecode(response.body);
      debugPrint('❌ API: Failed to save FCM token - ${data['error']}');
      throw Exception(data['error'] ?? 'Failed to save FCM token');
    }
  }

}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/utils/constant.dart'; // Ensure kBackendApiUrl is defined here
import 'package:flutter_riverpod/legacy.dart';

// --- SERVICE ---
class ProfileService {
  final _storage = const FlutterSecureStorage();

  Future<String> _getToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');
    return token;
  }

  // GET: /settings/statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$kBackendApiUrl/settings/statistics'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching stats: $e');
    }
  }

  // DELETE: /settings/clear-history
  Future<void> clearQuizHistory() async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$kBackendApiUrl/settings/clear-history'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear history');
    }
  }

  // DELETE: /settings/delete-account
  Future<void> deleteAccount(String email) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$kBackendApiUrl/settings/delete-account'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      // Backend requires confirmEmail in body
      body: json.encode({'confirmEmail': email}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete account');
    }
  }

  // GET: /settings/download-data
  Future<Map<String, dynamic>> downloadUserData() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$kBackendApiUrl/settings/download-data'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to download data');
    }
  }
}

// --- PROVIDERS ---

// 1. Stats State
class ProfileStats {
  final int totalQuizzes;
  final int averageScore;
  final int perfectScores;
  final int totalPoints;
  final int createdQuizzes;
  final bool isLoading;
  final String? error;

  ProfileStats({
    this.totalQuizzes = 0,
    this.averageScore = 0,
    this.perfectScores = 0,
    this.totalPoints = 0,
    this.createdQuizzes = 0,
    this.isLoading = true,
    this.error,
  });
}

// 2. Stats Notifier
class ProfileStatsNotifier extends StateNotifier<ProfileStats> {
  ProfileStatsNotifier() : super(ProfileStats()) {
    loadStatistics();
  }

  final _service = ProfileService();

  Future<void> loadStatistics() async {
    // Don't set loading to true if we already have data (silent refresh)
    if (state.totalQuizzes == 0) {
      state = ProfileStats(isLoading: true);
    }
    
    try {
      final stats = await _service.getUserStatistics();
      state = ProfileStats(
        totalQuizzes: stats['totalQuizzes'] ?? 0,
        averageScore: stats['averageScore'] ?? 0,
        perfectScores: stats['perfectScores'] ?? 0,
        totalPoints: stats['totalPoints'] ?? 0,
        createdQuizzes: stats['createdQuizzes'] ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = ProfileStats(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async => await loadStatistics();
}

final profileStatsProvider = StateNotifierProvider<ProfileStatsNotifier, ProfileStats>((ref) {
  return ProfileStatsNotifier();
});

// 3. Service Provider (For direct access in UI)
final profileServiceProvider = Provider((ref) => ProfileService());
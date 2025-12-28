import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:quirzy/features/auth/data/auth_repository.dart';
import 'package:quirzy/features/quiz/data/quiz_repository.dart';

/// Dependency Injection Container
///
/// Provides a centralized location for all dependencies
/// Following the clean architecture pattern for dependency management

// ============== HTTP Client ==============
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// ============== Repositories ==============

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Quiz Repository Provider
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(client: ref.watch(httpClientProvider));
});

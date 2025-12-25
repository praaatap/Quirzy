import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:quirzy/data/datasources/local/auth_local_datasource.dart';
import 'package:quirzy/data/datasources/remote/auth_remote_datasource.dart';
import 'package:quirzy/data/datasources/remote/quiz_remote_datasource.dart';
import 'package:quirzy/data/repositories/auth_repository.dart';
import 'package:quirzy/data/repositories/quiz_repository.dart';
import 'package:quirzy/domain/usecases/auth_usecases.dart';
import 'package:quirzy/domain/usecases/quiz_usecases.dart';

/// Dependency Injection Container
///
/// Provides a centralized location for all dependencies
/// Following the clean architecture pattern for dependency management

// ============== HTTP Client ==============
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// ============== Data Sources ==============

/// Auth Remote Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return AuthRemoteDataSource(client: client);
});

/// Auth Local Data Source Provider
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource();
});

/// Quiz Remote Data Source Provider
final quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return QuizRemoteDataSource(client: client);
});

// ============== Repositories ==============

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

/// Quiz Repository Provider
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(
    remoteDataSource: ref.watch(quizRemoteDataSourceProvider),
    authLocalDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

// ============== Use Cases ==============

/// Auth Use Cases Provider
final authUseCasesProvider = Provider<AuthUseCases>((ref) {
  return AuthUseCases(repository: ref.watch(authRepositoryProvider));
});

/// Quiz Use Cases Provider
final quizUseCasesProvider = Provider<QuizUseCases>((ref) {
  return QuizUseCases(repository: ref.watch(quizRepositoryProvider));
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/app_providers.dart';

/// Logout Use Case - handles user logout
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(authService: ref.watch(authServiceProvider));
});

class LogoutUseCase {
  final dynamic _authService;

  LogoutUseCase({required dynamic authService}) : _authService = authService;

  Future<void> call() async {
    await _authService.logout();
  }
}

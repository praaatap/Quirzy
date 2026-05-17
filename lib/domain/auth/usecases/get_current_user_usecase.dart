import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart';
import '../../../core/di/app_providers.dart';
import '../entities/auth_user.dart';

/// Get Current User Use Case - retrieves currently authenticated user
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(authService: ref.watch(authServiceProvider));
});

class GetCurrentUserUseCase {
  final dynamic _authService;

  GetCurrentUserUseCase({required dynamic authService})
      : _authService = authService;

  Future<AuthUser?> call() async {
    try {
      final User? user = await _authService.getCurrentUser();
      if (user == null) return null;

      final prefs = user.prefs.data;
      return AuthUser(
        id: user.$id,
        email: user.email,
        name: user.name,
        photoUrl: prefs['photoUrl'] as String?,
      );
    } catch (e) {
      debugPrint('GetCurrentUserUseCase error: $e');
      return null;
    }
  }
}

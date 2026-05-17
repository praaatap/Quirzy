import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart';
import '../../../core/di/app_providers.dart';
import '../entities/auth_user.dart';

/// Sign Up Use Case - handles email/password registration
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(authService: ref.watch(authServiceProvider));
});

class SignUpUseCase {
  final dynamic _authService;

  SignUpUseCase({required dynamic authService}) : _authService = authService;

  Future<AuthUser> call({
    required String email,
    required String password,
    required String name,
  }) async {
    final User user = await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );
    final prefs = user.prefs.data;
    return AuthUser(
      id: user.$id,
      email: user.email,
      name: user.name,
      photoUrl: prefs['photoUrl'] as String?,
    );
  }
}

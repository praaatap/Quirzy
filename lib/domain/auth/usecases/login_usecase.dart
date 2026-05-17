import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/models.dart';
import '../../../core/di/app_providers.dart';
import '../entities/auth_user.dart';

/// Login Use Case - handles email/password login
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(authService: ref.watch(authServiceProvider));
});

class LoginUseCase {
  final dynamic _authService;

  LoginUseCase({required dynamic authService}) : _authService = authService;

  Future<AuthUser> call({required String email, required String password}) async {
    final User user = await _authService.signIn(email: email, password: password);
    final prefs = user.prefs.data;
    return AuthUser(
      id: user.$id,
      email: user.email,
      name: user.name,
      photoUrl: prefs['photoUrl'] as String?,
    );
  }
}

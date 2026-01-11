import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/providers/auth_provider.dart';

class AuthListenator extends ChangeNotifier {
  AuthListenator(Ref ref) {
    ref.listen(authProvider, (_, _) {
      notifyListeners();
    });
  }
}

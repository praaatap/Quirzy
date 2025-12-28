import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Storage instance
  static const storage = FlutterSecureStorage();

  // Keys
  static const keyToken = 'token';
  static const keyEmail = 'user_email';
  static const keyName = 'user_name';

  // --- Token Management ---

  static Future<String?> getToken() async {
    return await storage.read(key: keyToken);
  }

  static Future<void> saveToken(String token) async {
    await storage.write(key: keyToken, value: token);
  }

  static Future<void> deleteToken() async {
    await storage.delete(key: keyToken);
  }

  // --- User Data Management ---

  static Future<String?> getEmail() async {
    return await storage.read(key: keyEmail);
  }

  static Future<void> saveEmail(String email) async {
    await storage.write(key: keyEmail, value: email);
  }

  static Future<String?> getName() async {
    return await storage.read(key: keyName);
  }

  static Future<void> saveName(String name) async {
    await storage.write(key: keyName, value: name);
  }

  // --- Clear Data ---

  static Future<void> clearAll() async {
    await storage.deleteAll();
  }
}

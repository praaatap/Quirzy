import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:quirzy/utils/constant.dart';

class UserDataService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS Simulator
  final String _baseUrl = kBackendApiUrl; 
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> downloadUserData() async {
    try {
      // DEBUG: Print all keys to console so you can see what the token is actually named
      final allKeys = await _storage.readAll();
      debugPrint('🔑 KEYS IN STORAGE: ${allKeys.keys.toString()}');

      // 1. Get Authentication Token
      // CHECK THIS: specific key name must match what you used in LoginScreen
      String? token = await _storage.read(key: 'auth_token');
      
      // Fallback: If 'auth_token' is null, try common alternatives
      token ??= await _storage.read(key: 'token');
      token ??= await _storage.read(key: 'jwt');

      if (token == null) {
        return {
          'success': false, 
          'message': 'Token not found. Storage keys: ${allKeys.keys}'
        };
      }

      // 2. Request Storage Permissions
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        return {
          'success': false,
          'message': 'Storage permission denied. Cannot save file.'
        };
      }

      // 3. Make the API Call
      // FIXED: Changed from /users/export-data to /settings/download-data
      final response = await http.get(
        Uri.parse('$_baseUrl/settings/download-data'), 
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // 4. Get Download Directory
        String? savePath = await _getDownloadPath();
        if (savePath == null) {
          return {'success': false, 'message': 'Could not locate download folder'};
        }

        // 5. Generate Filename
        String fileName = 'quirzy-data-${DateTime.now().millisecondsSinceEpoch}.json';
        
        // Try to get filename from server headers
        String? contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null && contentDisposition.contains('filename=')) {
          try {
            fileName = contentDisposition.split('filename=')[1].replaceAll('"', '');
          } catch (_) {
            // keep default filename on parse error
          }
        }

        // 6. Write the file
        final file = File('$savePath/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        debugPrint('✅ File saved to: ${file.path}');
        
        return {
          'success': true,
          'message': 'Saved to Downloads folder!',
          'filename': fileName,
          'path': file.path
        };
      } else {
        debugPrint('❌ Server Error: ${response.body}');
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      
      // Android 13+ (SDK 33) does not use WRITE_EXTERNAL_STORAGE
      if (androidInfo.version.sdkInt >= 33) {
        return true; 
      }
      
      // Android 10-12
      var status = await Permission.storage.status;
      if (status.isGranted) return true;
      
      var result = await Permission.storage.request();
      return result.isGranted;
    }
    return false;
  }

  Future<String?> _getDownloadPath() async {
    try {
      if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;
      } else {
        // Android: Try the public Download folder
        Directory dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) {
          return dir.path;
        }
        // Fallback
        final externalDir = await getExternalStorageDirectory();
        return externalDir?.path;
      }
    } catch (err) {
      debugPrint("❌ Cannot get download folder path: $err");
      return null;
    }
  }
}
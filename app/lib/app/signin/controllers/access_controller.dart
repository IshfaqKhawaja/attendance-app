// Access Token and Refresh Token Related INFO:
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccessController {
  static Future<void> saveTokens(String access, String refresh) async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: 'access_token', value: access);
    await secureStorage.write(key: 'refresh_token', value: refresh);
  }

  static Future<String?> getAccessToken() async {
    final secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'access_token');
  }

  static Future<String?> getRefreshToke() async {
    final secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'refresh_token');
  }

  static Future<Map<String, dynamic>> makeHeader(
    Map<String, dynamic> header,
  ) async {
    header["access_token"] = await AccessController.getAccessToken();
    return header;
  }

  static Future<void> clearTokens() async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'refresh_token');
    await secureStorage.delete(key: 'user_data');
  }

  /// Save user data for auto-login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.write(key: 'user_data', value: jsonEncode(userData));
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final secureStorage = FlutterSecureStorage();
    final data = await secureStorage.read(key: 'user_data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }
}

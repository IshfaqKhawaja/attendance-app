// Access Token and Refresh Token Related INFO:
import 'dart:convert';

import '../../core/utils/platform_utils.dart';

// Conditional imports for storage
import 'access_controller_mobile.dart'
    if (dart.library.html) 'access_controller_web.dart' as storage_impl;

class AccessController {
  static Future<void> saveTokens(String access, String refresh) async {
    await storage_impl.StorageImpl.saveTokens(access, refresh);
  }

  static Future<String?> getAccessToken() async {
    return await storage_impl.StorageImpl.getAccessToken();
  }

  static Future<String?> getRefreshToke() async {
    return await storage_impl.StorageImpl.getRefreshToken();
  }

  static Future<Map<String, dynamic>> makeHeader(
    Map<String, dynamic> header,
  ) async {
    header["access_token"] = await AccessController.getAccessToken();
    return header;
  }

  static Future<void> clearTokens() async {
    await storage_impl.StorageImpl.clearTokens();
  }

  /// Save user data for auto-login
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await storage_impl.StorageImpl.saveUserData(jsonEncode(userData));
  }

  /// Get saved user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await storage_impl.StorageImpl.getUserData();
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  /// Check if running on web platform
  static bool get isWeb => PlatformUtils.isWeb;
}

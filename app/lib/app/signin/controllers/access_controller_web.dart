import 'package:web/web.dart' as web;

/// Web implementation using localStorage
/// Note: localStorage is not as secure as mobile secure storage,
/// but it's the best option available for web browsers
class StorageImpl {
  static const String _accessTokenKey = 'attendance_access_token';
  static const String _refreshTokenKey = 'attendance_refresh_token';
  static const String _userDataKey = 'attendance_user_data';

  static Future<void> saveTokens(String access, String refresh) async {
    web.window.localStorage.setItem(_accessTokenKey, access);
    web.window.localStorage.setItem(_refreshTokenKey, refresh);
  }

  static Future<String?> getAccessToken() async {
    return web.window.localStorage.getItem(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return web.window.localStorage.getItem(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    web.window.localStorage.removeItem(_accessTokenKey);
    web.window.localStorage.removeItem(_refreshTokenKey);
    web.window.localStorage.removeItem(_userDataKey);
  }

  static Future<void> saveUserData(String userData) async {
    web.window.localStorage.setItem(_userDataKey, userData);
  }

  static Future<String?> getUserData() async {
    return web.window.localStorage.getItem(_userDataKey);
  }
}

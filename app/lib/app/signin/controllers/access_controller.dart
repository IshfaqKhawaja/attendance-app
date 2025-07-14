// Access Token and Refresh Token Related INFO:
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
}

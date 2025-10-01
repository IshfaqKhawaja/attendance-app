import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import 'base_service.dart';

/// App settings and preferences service
/// 
/// Features:
/// - Secure storage for sensitive settings
/// - User preferences management
/// - App configuration persistence
/// - Theme and language settings
/// - Privacy and security settings
class SettingsService extends BaseService {
  static SettingsService get to => Get.find();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // App settings observables
  final RxBool isDarkMode = false.obs;
  final RxString language = 'en'.obs;
  final RxBool biometricEnabled = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool autoSync = true.obs;
  final RxInt syncInterval = 5.obs; // minutes
  final RxBool offlineMode = false.obs;
  final RxString serverUrl = 'https://api.example.com'.obs;
  
  // Privacy settings
  final RxBool analyticsEnabled = true.obs;
  final RxBool crashReportingEnabled = true.obs;
  final RxBool dataSharingEnabled = false.obs;
  
  // App preferences
  final RxInt attendanceReminderHour = 9.obs;
  final RxInt attendanceReminderMinute = 0.obs;
  final RxBool showAttendanceStats = true.obs;
  final RxInt defaultPageSize = 20.obs;
  
  @override
  Future<void> initialize() async {
    try {
      await _loadAllSettings();
      Get.log('SettingsService initialized');
    } catch (e) {
      Get.log('Failed to initialize SettingsService: $e');
      rethrow;
    }
  }
  
  Future<void> _loadAllSettings() async {
    try {
      // Load app settings
      isDarkMode.value = await _getBool('dark_mode', defaultValue: false);
      language.value = await _getString('language', defaultValue: 'en');
      biometricEnabled.value = await _getBool('biometric_enabled', defaultValue: false);
      notificationsEnabled.value = await _getBool('notifications_enabled', defaultValue: true);
      autoSync.value = await _getBool('auto_sync', defaultValue: true);
      syncInterval.value = await _getInt('sync_interval', defaultValue: 5);
      offlineMode.value = await _getBool('offline_mode', defaultValue: false);
      serverUrl.value = await _getString('server_url', defaultValue: 'https://api.example.com');
      
      // Load privacy settings
      analyticsEnabled.value = await _getBool('analytics_enabled', defaultValue: true);
      crashReportingEnabled.value = await _getBool('crash_reporting_enabled', defaultValue: true);
      dataSharingEnabled.value = await _getBool('data_sharing_enabled', defaultValue: false);
      
      // Load app preferences
      attendanceReminderHour.value = await _getInt('reminder_hour', defaultValue: 9);
      attendanceReminderMinute.value = await _getInt('reminder_minute', defaultValue: 0);
      showAttendanceStats.value = await _getBool('show_attendance_stats', defaultValue: true);
      defaultPageSize.value = await _getInt('default_page_size', defaultValue: 20);
      
      Get.log('Settings loaded successfully');
    } catch (e) {
      Get.log('Error loading settings: $e');
    }
  }
  
  // Theme settings
  Future<void> setDarkMode(bool enabled) async {
    isDarkMode.value = enabled;
    await _setBool('dark_mode', enabled);
    Get.changeThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }
  
  Future<void> toggleTheme() async {
    await setDarkMode(!isDarkMode.value);
  }
  
  // Language settings
  Future<void> setLanguage(String languageCode) async {
    language.value = languageCode;
    await _setString('language', languageCode);
    
    // Update app locale
    final locale = Locale(languageCode);
    Get.updateLocale(locale);
  }
  
  // Security settings
  Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled.value = enabled;
    await _setBool('biometric_enabled', enabled);
  }
  
  // Notification settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _setBool('notifications_enabled', enabled);
  }
  
  // Sync settings
  Future<void> setAutoSync(bool enabled) async {
    autoSync.value = enabled;
    await _setBool('auto_sync', enabled);
  }
  
  Future<void> setSyncInterval(int minutes) async {
    syncInterval.value = minutes;
    await _setInt('sync_interval', minutes);
  }
  
  // Offline mode
  Future<void> setOfflineMode(bool enabled) async {
    offlineMode.value = enabled;
    await _setBool('offline_mode', enabled);
  }
  
  // Server configuration
  Future<void> setServerUrl(String url) async {
    serverUrl.value = url;
    await _setString('server_url', url);
  }
  
  // Privacy settings
  Future<void> setAnalyticsEnabled(bool enabled) async {
    analyticsEnabled.value = enabled;
    await _setBool('analytics_enabled', enabled);
  }
  
  Future<void> setCrashReportingEnabled(bool enabled) async {
    crashReportingEnabled.value = enabled;
    await _setBool('crash_reporting_enabled', enabled);
  }
  
  Future<void> setDataSharingEnabled(bool enabled) async {
    dataSharingEnabled.value = enabled;
    await _setBool('data_sharing_enabled', enabled);
  }
  
  // App preferences
  Future<void> setAttendanceReminderTime(int hour, int minute) async {
    attendanceReminderHour.value = hour;
    attendanceReminderMinute.value = minute;
    await _setInt('reminder_hour', hour);
    await _setInt('reminder_minute', minute);
  }
  
  Future<void> setShowAttendanceStats(bool enabled) async {
    showAttendanceStats.value = enabled;
    await _setBool('show_attendance_stats', enabled);
  }
  
  Future<void> setDefaultPageSize(int size) async {
    defaultPageSize.value = size;
    await _setInt('default_page_size', size);
  }
  
  // Authentication tokens (secure storage)
  Future<void> saveAuthTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'access_token');
  }
  
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }
  
  Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
  }
  
  // User session data (secure storage)
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    await _secureStorage.write(key: 'user_data', value: userData.toString());
  }
  
  Future<String?> getUserSession() async {
    return await _secureStorage.read(key: 'user_data');
  }
  
  Future<void> clearUserSession() async {
    await _secureStorage.delete(key: 'user_data');
  }
  
  // Settings export/import
  Future<Map<String, dynamic>> exportSettings() async {
    return {
      'dark_mode': isDarkMode.value,
      'language': language.value,
      'notifications_enabled': notificationsEnabled.value,
      'auto_sync': autoSync.value,
      'sync_interval': syncInterval.value,
      'analytics_enabled': analyticsEnabled.value,
      'crash_reporting_enabled': crashReportingEnabled.value,
      'reminder_hour': attendanceReminderHour.value,
      'reminder_minute': attendanceReminderMinute.value,
      'show_attendance_stats': showAttendanceStats.value,
      'default_page_size': defaultPageSize.value,
    };
  }
  
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings.containsKey('dark_mode')) {
        await setDarkMode(settings['dark_mode'] as bool);
      }
      if (settings.containsKey('language')) {
        await setLanguage(settings['language'] as String);
      }
      if (settings.containsKey('notifications_enabled')) {
        await setNotificationsEnabled(settings['notifications_enabled'] as bool);
      }
      if (settings.containsKey('auto_sync')) {
        await setAutoSync(settings['auto_sync'] as bool);
      }
      if (settings.containsKey('sync_interval')) {
        await setSyncInterval(settings['sync_interval'] as int);
      }
      
      Get.log('Settings imported successfully');
    } catch (e) {
      Get.log('Error importing settings: $e');
      rethrow;
    }
  }
  
  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await setDarkMode(false);
    await setLanguage('en');
    await setBiometricEnabled(false);
    await setNotificationsEnabled(true);
    await setAutoSync(true);
    await setSyncInterval(5);
    await setOfflineMode(false);
    await setAnalyticsEnabled(true);
    await setCrashReportingEnabled(true);
    await setDataSharingEnabled(false);
    await setAttendanceReminderTime(9, 0);
    await setShowAttendanceStats(true);
    await setDefaultPageSize(20);
    
    Get.log('Settings reset to defaults');
  }
  
  // Clear all app data
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await resetToDefaults();
    Get.log('All app data cleared');
  }
  
  // Helper methods for secure storage
  Future<bool> _getBool(String key, {bool defaultValue = false}) async {
    final value = await _secureStorage.read(key: key);
    return value?.toLowerCase() == 'true' ? true : defaultValue;
  }
  
  Future<void> _setBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }
  
  Future<String> _getString(String key, {String defaultValue = ''}) async {
    final value = await _secureStorage.read(key: key);
    return value ?? defaultValue;
  }
  
  Future<void> _setString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  Future<int> _getInt(String key, {int defaultValue = 0}) async {
    final value = await _secureStorage.read(key: key);
    return value != null ? int.tryParse(value) ?? defaultValue : defaultValue;
  }
  
  Future<void> _setInt(String key, int value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }
  
  // Get settings summary for debugging
  Map<String, dynamic> getSettingsSummary() {
    return {
      'theme': isDarkMode.value ? 'dark' : 'light',
      'language': language.value,
      'biometric': biometricEnabled.value,
      'notifications': notificationsEnabled.value,
      'autoSync': autoSync.value,
      'syncInterval': '${syncInterval.value} minutes',
      'offlineMode': offlineMode.value,
      'analytics': analyticsEnabled.value,
    };
  }
}
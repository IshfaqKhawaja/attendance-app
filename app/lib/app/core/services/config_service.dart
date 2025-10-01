import 'package:get/get.dart';
import 'base_service.dart';

/// Service for managing application-wide state and configuration
class ConfigService extends BaseService {
  static ConfigService get to => Get.find<ConfigService>();
  
  // App configuration
  final RxString _appVersion = '1.0.0'.obs;
  final RxString _apiBaseUrl = ''.obs;
  final RxBool _isDevelopmentMode = true.obs;
  final RxString _appName = 'JMI Attendance'.obs;
  
  // Getters
  String get appVersion => _appVersion.value;
  String get apiBaseUrl => _apiBaseUrl.value;
  bool get isDevelopmentMode => _isDevelopmentMode.value;
  String get appName => _appName.value;
  
  @override
  Future<void> initialize() async {
    // Load configuration from environment or assets
    await _loadConfiguration();
    Get.log('ConfigService initialized successfully');
  }
  
  Future<void> _loadConfiguration() async {
    // In a real app, this would load from environment variables or config files
    _apiBaseUrl.value = _isDevelopmentMode.value 
      ? 'http://localhost:8000/api' 
      : 'https://api.jmiattendance.com';
  }
  
  /// Update API base URL
  void setApiBaseUrl(String url) {
    _apiBaseUrl.value = url;
  }
  
  /// Toggle development mode
  void setDevelopmentMode(bool isDev) {
    _isDevelopmentMode.value = isDev;
    _loadConfiguration(); // Reload config based on mode
  }
}
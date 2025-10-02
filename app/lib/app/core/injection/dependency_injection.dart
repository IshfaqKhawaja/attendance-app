import 'package:get/get.dart';
import '../services/services.dart';
import '../services/user_role_service.dart';

import '../../signin/controllers/signin_controller.dart';
import '../../loading/controllers/loading_controller.dart';

/// Service for managing dependency injection and initialization
class DependencyInjection {
  /// Initialize all essential services and controllers
  static Future<void> init() async {
    Get.log('🚀 Starting Dependency Injection...');
    
    // Initialize core services first
    await _initCoreServices();
    
    // Initialize essential controllers
    await _initEssentialControllers();
    
    Get.log('✅ Dependency Injection completed successfully');
  }
  
  /// Initialize core services that other services depend on
  static Future<void> _initCoreServices() async {
    Get.log('🔧 Initializing core services...');
    
    // Config service first (provides configuration for other services)
    Get.put(ConfigService(), permanent: true);
    await Get.find<ConfigService>().initialize();
    
    // API service (depends on config)
    Get.put(ApiService(), permanent: true);
    await Get.find<ApiService>().initialize();
    
    // Navigation service
    Get.put(NavigationService(), permanent: true);
    
    // Error handling service
    Get.put(ErrorHandlingService(), permanent: true);
    await Get.find<ErrorHandlingService>().initialize();
    
    // Enhanced services
    Get.put(ConnectivityService(), permanent: true);
    await Get.find<ConnectivityService>().initialize();
    
    Get.put(LocalDatabaseService(), permanent: true);
    await Get.find<LocalDatabaseService>().initialize();
    
    Get.put(BiometricService(), permanent: true);
    await Get.find<BiometricService>().initialize();
    
    Get.put(NotificationService(), permanent: true);
    await Get.find<NotificationService>().initialize();
    
    Get.log('✅ Core services initialized with enhanced functionality');
  }
  
  /// Initialize essential controllers that should be available app-wide
  static Future<void> _initEssentialControllers() async {
    Get.log('🎮 Initializing essential controllers...');
    
    // Sign-in controller (authentication state)
    Get.put(SignInController(), permanent: true);
    
    // User role service (depends on SignInController)
    Get.put(UserRoleService(), permanent: true);
    
    // Loading controller (app-wide loading state)
    Get.put(LoadingController(), permanent: true);
    
    Get.log('✅ Essential controllers initialized');
  }
  
  /// Clean up all dependencies (useful for app restart or testing)
  static Future<void> cleanup() async {
    Get.log('🧹 Cleaning up dependencies...');
    
    // Delete all controllers and services
    await Get.deleteAll(force: true);
    
    Get.log('✅ Cleanup completed');
  }
  
  /// Reset and reinitialize all dependencies
  static Future<void> reset() async {
    await cleanup();
    await init();
  }
}
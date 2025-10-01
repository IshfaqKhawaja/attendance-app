import 'package:get/get.dart';
import 'base_service.dart';
import 'config_service.dart';

/// Service for managing app-wide error handling and logging
class ErrorHandlingService extends BaseService {
  static ErrorHandlingService get to => Get.find<ErrorHandlingService>();

  final RxList<String> _errorLog = <String>[].obs;
  final RxString _lastError = ''.obs;
  
  /// Get list of all logged errors
  List<String> get errorLog => _errorLog.toList();
  
  /// Get the last error that occurred
  String get lastError => _lastError.value;
  
  @override
  Future<void> initialize() async {
    // Set up global error handling
    _setupGlobalErrorHandling();
    Get.log('ErrorHandlingService initialized successfully');
  }
  
  /// Set up global error handling for the app
  void _setupGlobalErrorHandling() {
    // This could integrate with crash reporting services like Firebase Crashlytics
  }
  
  /// Log an error with context
  void logError(String error, {
    String? context,
    dynamic stackTrace,
    bool showToUser = false,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] ${context ?? "Unknown"}: $error';
    
    _errorLog.add(logEntry);
    _lastError.value = error;
    
    // Log to console in debug mode
    if (ConfigService.to.isDevelopmentMode) {
      Get.log('ERROR: $logEntry');
      if (stackTrace != null) {
        Get.log('STACK: $stackTrace');
      }
    }
    
    // Show error to user if requested
    if (showToUser) {
      _showErrorToUser(error);
    }
    
    // Keep only last 100 errors to prevent memory issues
    if (_errorLog.length > 100) {
      _errorLog.removeAt(0);
    }
  }
  
  /// Show error message to user
  void _showErrorToUser(String error) {
    Get.snackbar(
      'Error',
      error,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
      colorText: Get.theme.colorScheme.onError,
    );
  }
  
  /// Clear error log
  void clearErrorLog() {
    _errorLog.clear();
    _lastError.value = '';
  }
  
  /// Handle network errors specifically
  void handleNetworkError(dynamic error, {String? context}) {
    String message = 'Network error occurred';
    
    if (error.toString().contains('SocketException')) {
      message = 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      message = 'Request timed out';
    } else if (error.toString().contains('401')) {
      message = 'Authentication failed';
    } else if (error.toString().contains('403')) {
      message = 'Access denied';
    } else if (error.toString().contains('404')) {
      message = 'Resource not found';
    } else if (error.toString().contains('500')) {
      message = 'Server error';
    }
    
    logError(message, context: context ?? 'Network', showToUser: true);
  }
}
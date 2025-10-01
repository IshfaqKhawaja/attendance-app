import 'package:get/get.dart';

/// Base service class that provides common functionality for all services
abstract class BaseService extends GetxService {
  /// Indicates if the service has been initialized
  final RxBool _isInitialized = false.obs;
  
  /// Returns true if the service has been properly initialized
  bool get isInitialized => _isInitialized.value;
  
  /// Abstract method that must be implemented by all services
  Future<void> initialize();
  
  /// Base onInit that calls initialize
  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }
  
  /// Internal method to handle initialization
  Future<void> _initializeService() async {
    try {
      await initialize();
      _isInitialized.value = true;
    } catch (e) {
      Get.log('Error initializing ${runtimeType.toString()}: $e');
      rethrow;
    }
  }
  
  /// Method to check if service is ready to use
  void ensureInitialized() {
    if (!isInitialized) {
      throw Exception('${runtimeType.toString()} is not initialized');
    }
  }
}
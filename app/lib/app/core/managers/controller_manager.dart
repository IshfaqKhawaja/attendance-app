import 'package:get/get.dart';

/// Controller Manager for proper lifecycle management
/// 
/// Handles:
/// - Controller registration and disposal
/// - Dependency management
/// - Memory leak prevention
class ControllerManager {
  static final Map<String, GetxController> _permanentControllers = {};
  
  /// Register a permanent controller
  static T putPermanent<T extends GetxController>(
    T controller, {
    String? tag,
  }) {
    final key = _getKey<T>(tag);
    
    // If controller already exists, return it
    if (_permanentControllers.containsKey(key)) {
      return _permanentControllers[key] as T;
    }
    
    // Put new controller and register it
    final putController = Get.put<T>(controller, permanent: true, tag: tag);
    _permanentControllers[key] = putController;
    
    return putController;
  }
  
  /// Find a controller or create if not exists
  static T findOrPut<T extends GetxController>(
    T Function() factory, {
    String? tag,
    bool permanent = false,
  }) {
    try {
      return Get.find<T>(tag: tag);
    } catch (e) {
      final controller = factory();
      if (permanent) {
        return putPermanent<T>(controller, tag: tag);
      } else {
        return Get.put<T>(controller, tag: tag);
      }
    }
  }
  
  /// Safely delete a controller
  static Future<bool> safeDelete<T extends GetxController>({String? tag}) async {
    try {
      final key = _getKey<T>(tag);
      _permanentControllers.remove(key);
      return await Get.delete<T>(tag: tag);
    } catch (e) {
      print('Warning: Could not delete controller ${T.toString()}: $e');
      return false;
    }
  }
  
  /// Clear all non-permanent controllers
  static void clearNonPermanent() {
    try {
      // Clear controllers that are not in permanent list
      for (final key in List.from(_permanentControllers.keys)) {
        if (!_permanentControllers.containsKey(key)) {
          try {
            Get.delete(tag: key);
          } catch (e) {
            // Ignore errors for controllers that can't be deleted
          }
        }
      }
    } catch (e) {
      print('Warning: Error clearing non-permanent controllers: $e');
    }
  }
  
  /// Reset all controllers (use with caution)
  static void resetAll({List<Type> exclude = const []}) {
    try {
      // Save excluded controllers
      final Map<String, GetxController> saved = {};
      for (final type in exclude) {
        final key = type.toString();
        if (_permanentControllers.containsKey(key)) {
          saved[key] = _permanentControllers[key]!;
        }
      }
      
      // Clear all
      Get.reset();
      _permanentControllers.clear();
      
      // Restore excluded controllers
      _permanentControllers.addAll(saved);
    } catch (e) {
      print('Warning: Error resetting controllers: $e');
    }
  }
  
  /// Check if an instance is already registered
  static bool isRegistered<T extends GetxController>({String? tag}) {
    try {
      Get.find<T>(tag: tag);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get all permanent controller keys
  static List<String> getPermanentControllerKeys() {
    return _permanentControllers.keys.toList();
  }
  
  static String _getKey<T>(String? tag) {
    return tag != null ? '${T.toString()}_$tag' : T.toString();
  }
}
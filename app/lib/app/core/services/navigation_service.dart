import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/base_controller.dart';

/// Service for managing navigation and routing
class NavigationService extends BaseController {
  static NavigationService get to => Get.find<NavigationService>();
  
  /// Navigate to route with optional arguments
  void navigateTo(String route, {dynamic arguments}) {
    safeNavigate(route, arguments: arguments);
  }
  
  /// Navigate and remove all previous routes
  void navigateAndClearStack(String route, {dynamic arguments}) {
    safeNavigateOffAll(route, arguments: arguments);
  }
  
  /// Navigate and replace current route
  void navigateAndReplace(String route, {dynamic arguments}) {
    Get.offNamed(route, arguments: arguments);
  }
  
  /// Go back to previous route
  void goBack({dynamic result}) {
    if (Navigator.canPop(Get.context!)) {
      Get.back(result: result);
    }
  }
  
  /// Go back until specific route
  void goBackUntil(String route) {
    Get.until((route_) => route_.settings.name == route);
  }
  
  /// Show bottom sheet
  void showBottomSheet(Widget content, {
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    Get.bottomSheet(
      content,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
    );
  }
  
  /// Show dialog
  void showDialog(Widget content, {
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      content,
      barrierDismissible: barrierDismissible,
    );
  }
}
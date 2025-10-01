import 'package:get/get.dart';
import '../controllers/main_dashboard_controller.dart';
import '../../../signin/controllers/signin_controller.dart';
import '../../../loading/controllers/loading_controller.dart';

/// Bindings for Main Dashboard
/// 
/// This class ensures all required controllers are properly initialized
/// before the MainDashboard is loaded.
class MainDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure LoadingController is available (it loads initial data)
    if (!Get.isRegistered<LoadingController>()) {
      Get.put<LoadingController>(
        LoadingController(),
        permanent: true,
      );
    }
    
    // Ensure SignInController is available
    if (!Get.isRegistered<SignInController>()) {
      Get.put<SignInController>(
        SignInController(),
        permanent: true,
      );
    }
    
    // Put MainDashboardController
    Get.lazyPut<MainDashboardController>(
      () => MainDashboardController(),
    );
  }
}
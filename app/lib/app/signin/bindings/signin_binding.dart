import 'package:get/get.dart';
import '../controllers/signin_controller.dart';

/// Bindings for Sign In page
/// 
/// Ensures SignInController is properly initialized before the sign-in page loads.
class SignInBinding extends Bindings {
  @override
  void dependencies() {
    // Put SignInController if not already registered
    if (!Get.isRegistered<SignInController>()) {
      Get.put<SignInController>(
        SignInController(),
        permanent: true,
      );
    }
  }
}
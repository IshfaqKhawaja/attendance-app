import 'package:get/get.dart';

// Core imports
import '../../../core/core.dart';
import '../../../routes/routes.dart';

// Feature imports
import '../../../signin/controllers/signin_controller.dart';
import '../../../signin/controllers/access_controller.dart';

class MainDashboardController extends BaseController {
  SignInController? _signInController;
  
  // Observable to track which dashboard should be shown
  final currentDashboard = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSignInController();
    _determineDashboard();
  }

  /// Initialize SignInController, create if doesn't exist
  void _initializeSignInController() {
    try {
      _signInController = Get.find<SignInController>();
      print("MainDashboardController: Found existing SignInController");
    } catch (e) {
      // SignInController not found, put a new one
      print("MainDashboardController: SignInController not found, creating new one");
      _signInController = Get.put(SignInController(), permanent: true);
    }
  }


  /// Determines which dashboard to show based on user data
  void _determineDashboard() {
    handleAsync(() async {
      // Ensure SignInController is available
      if (_signInController == null) {
        currentDashboard.value = Routes.SIGN_IN;
        return;
      }

      // First, try to restore user data from storage if not already loaded
      // This handles the auto-login scenario
      await _signInController!.restoreUserData();

      // Check if user data exists
      final userData = _signInController!.userData.value;
      final teacherData = _signInController!.teacherData.value;

      // Determine dashboard based on user type
      if (userData.type == "SUPER_ADMIN") {
        currentDashboard.value = Routes.SUPER_ADMIN_DASHBOARD;
      } else if (userData.type == "HOD") {
        currentDashboard.value = Routes.HOD_DASHBOARD;
      } else if (teacherData.teacherId.isNotEmpty) {
        currentDashboard.value = Routes.TEACHER_DASHBOARD;
      } else {
        // Fallback to sign in if no valid user data
        currentDashboard.value = Routes.SIGN_IN;
      }
    });
  }

  /// Refresh dashboard determination (useful after user data changes)
  void refreshDashboard() {
    _determineDashboard();
  }

  /// Navigate to the determined dashboard
  void navigateToDashboard() {
    if (currentDashboard.value.isNotEmpty) {
      Get.offAllNamed(currentDashboard.value);
    }
  }

  /// Get dashboard route without navigation
  String getDashboardRoute() {
    return currentDashboard.value;
  }

  /// Check if user is super admin
  bool get isSuperAdmin => (_signInController?.userData.value.type ?? "") == "SUPER_ADMIN";
  
  /// Check if user is HOD
  bool get isHod => (_signInController?.userData.value.type ?? "") == "HOD";
  
  /// Check if user is teacher
  bool get isTeacher => (_signInController?.teacherData.value.teacherId ?? "").isNotEmpty;

  /// Get user's department ID (works for both HOD and Teacher)
  String? get userDeptId {
    if (isHod || isSuperAdmin) {
      return _signInController?.userData.value.deptId;
    } else if (isTeacher) {
      return _signInController?.teacherData.value.deptId;
    }
    return null;
  }

  /// Get user's faculty ID (mainly for super admin)
  String? get userFactId {
    return _signInController?.userData.value.factId;
  }

  /// Sign out the current user
  Future<void> signOut() async {
    return handleAsync(
      () async {
        // Clear stored tokens
        await AccessController.clearTokens();
        
        // Reset all user data in SignInController if it exists
        if (_signInController != null) {
          _signInController!.resetUserData();
          _signInController!.clearForm();
        }
        
        // Clear specific controllers but keep SignInController
        Get.delete<MainDashboardController>();
        // Clear other dashboard controllers
        try {
          Get.delete(tag: 'teacher_dashboard');
          Get.delete(tag: 'hod_dashboard');
          Get.delete(tag: 'super_admin_dashboard');
        } catch (e) {
          // Controllers might not exist, that's fine
        }
        
        // Navigate to sign in page
        safeNavigateOffAll(Routes.SIGN_IN);
      },
      successMessage: "Signed out successfully",
    );
  }

}
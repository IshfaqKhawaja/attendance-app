import 'package:app/app/core/controllers/base_controller.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:app/app/dashboard/super_admin/controllers/department_controller.dart';
import 'package:get/get.dart';

class SuperAdminDashboardController extends BaseController {
  late final SignInController _signInController;
  late final DepartmentController _departmentController;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _loadDashboardData();
  }

  void _initializeDependencies() {
    _signInController = Get.find<SignInController>();
    
    // Initialize department controller if not already registered
    if (!Get.isRegistered<DepartmentController>()) {
      Get.put(DepartmentController());
    }
    _departmentController = Get.find<DepartmentController>();
  }

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    await handleAsync(() async {
      // Departments are loaded through LoadingController
      // No need to explicitly load them here as DepartmentController
      // loads them based on faculty ID
    });
  }

  /// Load departments for a specific faculty
  Future<void> loadDepartmentsForFaculty(String facultyId) async {
    await handleAsync(() async {
      _departmentController.loadDepartments(facultyId);
    });
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  /// Get current user name
  String get userName => _signInController.userData.value.userName;

  /// Get departments count
  int get departmentsCount => _departmentController.departments.length;

  /// Check if departments are loaded
  bool get isDepartmentsLoaded => _departmentController.departments.isNotEmpty;

  // Wrapper method for compatibility with existing views
  Future<void> _loadDashboardData() async {
    await loadDashboardData();
  }
}
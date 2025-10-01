



import 'package:app/app/core/controllers/base_controller.dart';
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:app/app/models/department_model.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:app/app/dashboard/hod/controllers/hod_dashboard_controller.dart';
import 'package:get/get.dart';

class DepartmentController extends BaseController {
  late final LoadingController _loadingController;
  late final SignInController _signInController;
  
  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
  }

  void _initializeDependencies() {
    _loadingController = Get.find<LoadingController>();
    _signInController = Get.find<SignInController>();
  }

  /// Load departments by faculty ID
  Future<void> loadDepartments(String facultyId) async {
    await handleAsync(() async {
      if (facultyId.isEmpty) {
        throw Exception('Faculty ID cannot be empty');
      }

      departments.value = _loadingController.departments
          .where((dept) => dept.factId == facultyId)
          .toList();
    });
  }

  /// Navigate to HOD dashboard with department ID
  Future<void> navigateToHodDashboard(String deptId) async {
    await handleAsync(() async {
      if (deptId.isEmpty) {
        throw Exception('Department ID cannot be empty');
      }

      // Update user data with selected department
      _signInController.userData.value.deptId = deptId;
      
      // Navigate to HOD dashboard
      HodDashboardController.navigateTo(deptId: deptId);
    });
  }

  /// Clear departments list
  void clearDepartments() {
    departments.clear();
  }

  /// Get departments count
  int get departmentsCount => departments.length;

  /// Check if departments are loaded
  bool get hasDepartments => departments.isNotEmpty;

  /// Get department by ID
  DepartmentModel? getDepartmentById(String deptId) {
    try {
      return departments.firstWhere((dept) => dept.deptId == deptId);
    } catch (e) {
      return null;
    }
  }
}
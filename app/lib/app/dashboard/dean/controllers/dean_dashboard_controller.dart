import 'package:get/get.dart';
import 'package:app/app/core/controllers/base_controller.dart';
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:app/app/models/department_model.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:app/app/dashboard/hod/controllers/hod_dashboard_controller.dart';

class DeanDashboardController extends BaseController {
  late final LoadingController _loadingController;
  late final SignInController _signInController;

  final RxList<DepartmentModel> departments = <DepartmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    loadDepartments();
  }

  void _initializeDependencies() {
    _loadingController = Get.find<LoadingController>();
    _signInController = Get.find<SignInController>();
  }

  /// Get the faculty ID for the current Dean
  String? get facultyId => _signInController.userData.value.factId;

  /// Get the faculty name from loaded faculties
  String get facultyName {
    if (facultyId == null) return 'Faculty';
    try {
      final faculty = _loadingController.faculities.firstWhere(
        (f) => f.factId == facultyId,
      );
      return faculty.factName;
    } catch (e) {
      return 'Faculty';
    }
  }

  /// Get the Dean's name
  String get deanName => _signInController.userData.value.userName;

  /// Load departments for the Dean's faculty
  Future<void> loadDepartments() async {
    await handleAsync(() async {
      if (facultyId == null || facultyId!.isEmpty) {
        throw Exception('Faculty ID not found for Dean');
      }

      // Filter departments by faculty ID from already loaded data
      departments.value = _loadingController.departments
          .where((dept) => dept.factId == facultyId)
          .toList();
    });
  }

  /// Navigate to HOD dashboard with department ID
  void navigateToHodDashboard(String deptId) {
    print('DeanDashboardController.navigateToHodDashboard called with deptId: $deptId');
    if (deptId.isEmpty) {
      print('ERROR: Department ID is empty');
      return;
    }
    // Navigate to HOD dashboard for the selected department
    HodDashboardController.navigateTo(deptId: deptId);
  }

  /// Refresh departments list
  Future<void> refreshDepartments() async {
    await loadDepartments();
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

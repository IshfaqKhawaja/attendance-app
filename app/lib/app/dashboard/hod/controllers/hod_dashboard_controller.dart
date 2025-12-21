
import 'package:app/app/models/program_model.dart';
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:app/app/routes/app_routes.dart';
import 'package:app/app/core/controllers/base_controller.dart';
import 'package:get/get.dart';

class HodDashboardController extends BaseController {
  late final SignInController _signInController;
  late final LoadingController _loadingController;
  
  final RxList<ProgramModel> programs = <ProgramModel>[].obs;
  String? routeDeptId;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    _setupListeners();
  }

  void _initializeDependencies() {
    _signInController = Get.find<SignInController>();
    _loadingController = Get.find<LoadingController>();
  }

  void _setupListeners() {
    ever(_loadingController.programs, (_) => loadPrograms());
    ever(_signInController.userData, (_) => loadPrograms());
  }

  /// Load programs for the current department
  Future<void> loadPrograms() async {
    await handleAsync(() async {
      final deptId = routeDeptId ?? _signInController.userData.value.deptId;

      if (deptId == null || deptId.isEmpty) {
        // Clear programs and return silently during sign-out or when dept ID is not available
        programs.clear();
        isLoading.value = false;
        return;
      }

      programs.value = _loadingController.programs
          .where((program) => program.deptId == deptId)
          .toList();
      isLoading.value = false;

    });
  }

  /// Initialize controller with optional department ID
  void init({String? deptId}) {
    routeDeptId = deptId;
    loadPrograms();
  }

  /// Navigate to HOD Dashboard with optional department ID
  static void navigateTo({String? deptId}) {
    if (deptId != null) {
      final route = Routes.HOD_DASHBOARD_WITH_DEPT.replaceAll(':deptId', deptId);
      // Use toNamed with preventDuplicates: false to ensure navigation happens
      // even if a similar route exists in the stack
      Get.toNamed(route, preventDuplicates: false);
    } else {
      Get.toNamed(Routes.HOD_DASHBOARD, preventDuplicates: false);
    }
  }

  /// Get current department ID
  String? get currentDeptId => routeDeptId ?? _signInController.userData.value.deptId;

  /// Check if programs are available
  bool get hasPrograms => programs.isNotEmpty;

  /// Get programs count
  int get programsCount => programs.length;
  
  /// Check if current user is super admin
  bool get isSuperAdmin => _signInController.isSuperAdmin;
  
  /// Get department name for current department
  String? get departmentName {
    final deptId = currentDeptId;
    if (deptId == null) return null;
    
    final dept = _loadingController.departments
        .firstWhereOrNull((d) => d.deptId == deptId);
    return dept?.deptName;
  }
  
  /// Get faculty name for current department
  String? get facultyName {
    final deptId = currentDeptId;
    if (deptId == null) return null;
    
    final dept = _loadingController.departments
        .firstWhereOrNull((d) => d.deptId == deptId);
    if (dept == null) return null;
    
    final faculty = _loadingController.faculities
        .firstWhereOrNull((f) => f.factId == dept.factId);
    return faculty?.factName;
  }
}

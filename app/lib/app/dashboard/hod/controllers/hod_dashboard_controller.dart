
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
        throw Exception('Department ID not found');
      }

      programs.value = _loadingController.programs
          .where((program) => program.deptId == deptId)
          .toList();
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
      Get.toNamed(Routes.HOD_DASHBOARD_WITH_DEPT.replaceAll(':deptId', deptId));
    } else {
      Get.toNamed(Routes.HOD_DASHBOARD);
    }
  }

  /// Get current department ID
  String? get currentDeptId => routeDeptId ?? _signInController.userData.value.deptId;

  /// Check if programs are available
  bool get hasPrograms => programs.isNotEmpty;

  /// Get programs count
  int get programsCount => programs.length;
}

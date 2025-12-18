



import 'package:app/app/core/network/endpoints.dart';
import 'package:app/app/dashboard/hod/controllers/hod_dashboard_controller.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../models/teacher_model.dart';
import '../../../signin/controllers/signin_controller.dart';

class ManageTeachersController extends GetxController {
  var currentDeptId = ''.obs;
  var teachers = <Teacher>[].obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  final ApiClient client = ApiClient();
  var deptId = ''.obs;

  final SignInController signInController = Get.find<SignInController>();

  /// Get the effective department ID (from route parameter or signed-in user)
  String? get _effectiveDeptId {
    // First check if HodDashboardController has a route-based deptId (for SuperAdmin)
    if (Get.isRegistered<HodDashboardController>()) {
      final hodController = Get.find<HodDashboardController>();
      if (hodController.routeDeptId != null && hodController.routeDeptId!.isNotEmpty) {
        return hodController.routeDeptId;
      }
    }
    // Fall back to signed-in user's deptId
    return signInController.userData.value.deptId;
  }

  Future<void> loadTeachers() async {
    // Update deptId from effective source (route or userData)
    deptId.value = _effectiveDeptId ?? '';

    // If department ID is not available (e.g., during sign-out), clear teachers and return
    if (deptId.value.isEmpty) {
      teachers.clear();
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    try {
      final res = await client.getJson(Endpoints.displayTeacherByDeptId(deptId.value));
      if (res['success'] == true) {
        teachers.value = (res['teachers'] as List<dynamic>)
            .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
            .toList();
        errorMessage.value = '';
      } else {
        errorMessage.value = res['message'] ?? 'Failed to load teachers';
      }

    } catch (e) {
      errorMessage.value = 'Failed to load teachers';
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> deleteTeacher(String teacherId) async {
    // Implement the logic to delete a teacher using the API client
    try {
      var body = {
        "teacher_id": teacherId,
      };
      final response = await client.postJson(Endpoints.deleteTeacher, body);
      if (response['success'] == true) {
        Get.snackbar("Success", "Teacher deleted successfully");
        return true;
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
    return false;
  }
  @override
  void onInit() {
    super.onInit();
    deptId.value = _effectiveDeptId ?? '';
    loadTeachers();
    ever(signInController.userData, (_) {
        loadTeachers();
      }
    );
  }
}
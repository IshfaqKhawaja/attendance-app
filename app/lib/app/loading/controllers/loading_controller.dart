import 'package:app/app/routes/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../../models/program_model.dart';
import '../../models/faculty_model.dart';
import '../../models/department_model.dart';
import '../../signin/controllers/access_controller.dart';

class LoadingController extends GetxController {
  RxBool isDataLoaded = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isAuthenticated = false.obs;
  RxList<FacultyModel> faculities = <FacultyModel>[].obs;
  RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  RxList<ProgramModel> programs = <ProgramModel>[].obs;

  /// Check if user has valid tokens and auto-login
  Future<void> checkAuthentication() async {
    final accessToken = await AccessController.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      isAuthenticated.value = true;

      // Try to load user data from backend using the token
      try {
        // The SignInController will be initialized by MainDashboardController
        // For now, just navigate - the token will be used automatically
        Get.offAndToNamed(Routes.MAIN_DASHBOARD);
      } catch (e) {
        print("Error during auto-login: $e");
        // If there's an error (like invalid token), clear tokens and go to sign in
        await AccessController.clearTokens();
        isAuthenticated.value = false;
        Get.offAndToNamed(Routes.SIGN_IN);
      }
    } else {
      isAuthenticated.value = false;
      Get.offAndToNamed(Routes.SIGN_IN);
    }
  }

  void route() {
    // This will be called after data loading completes
    checkAuthentication();
  }

  void _showErrorSnackbar(String title, String message) {
    // Use WidgetsBinding to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        Get.snackbar(title, message);
      }
    });
  }

  void loadData() async {
    try {
      final client = ApiClient();
      final res = await client.getJson(Endpoints.getAllData);
      // HTTP validation already done in ApiClient
      if (res["success"] == true) {
          // Set data:
          faculities.value = (res["faculties"] as List<dynamic>)
              .map((e) => FacultyModel.fromJson(e as Map<String, dynamic>))
              .toList();
          departments.value = ((res["departments"] as List<dynamic>).map(
            (e) => DepartmentModel.fromJson(e as Map<String, dynamic>),
          )).toList();
          programs.value = ((res["programs"] as List<dynamic>).map(
            (e) => ProgramModel.fromJson(e as Map<String, dynamic>),
          )).toList();
          route();
      } else {
        errorMessage.value = "Couldn't Fetch Data from Server";
        _showErrorSnackbar("Error", errorMessage.value);
      }
    } catch (e) {
      print("$e");
      errorMessage.value = "$e";
      _showErrorSnackbar("ERROR", errorMessage.value);
    }
    isDataLoaded.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }
}

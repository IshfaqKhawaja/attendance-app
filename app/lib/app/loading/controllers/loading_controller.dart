import 'package:app/app/routes/app_routes.dart';
import 'package:get/get.dart';

import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../../models/program_model.dart';
import '../../models/faculty_model.dart';
import '../../models/department_model.dart';

class LoadingController extends GetxController {
  RxBool isDataLoaded = false.obs;
  RxList<FacultyModel> faculities = <FacultyModel>[].obs;
  RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  RxList<ProgramModel> programs = <ProgramModel>[].obs;

  void route() {
    Get.offAndToNamed(Routes.SIGN_IN);
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
        Get.snackbar("Error", "Couldn't Fetch Data from Server:");
      }
    } catch (e) {
      print("$e");
      Get.snackbar("ERROR", "$e");
    }
    isDataLoaded.value = true;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }
}

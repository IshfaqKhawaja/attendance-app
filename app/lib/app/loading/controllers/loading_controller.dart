import 'dart:convert';

import 'package:app/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/network_constants.dart';
import '../../models/program_model.dart';
import '../../models/faculty_model.dart';
import '../../models/department_model.dart';
import "../../models/course_model.dart";
import "../../models/semester_model.dart";

class LoadingController extends GetxController {
  RxBool isDataLoaded = false.obs;
  RxList<FacultyModel> faculities = <FacultyModel>[].obs;
  RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  RxList<ProgramModel> programs = <ProgramModel>[].obs;
  RxList<CourseModel> courses = <CourseModel>[].obs;
  RxList<SemesterModel> semesters = <SemesterModel>[].obs;

  void route() {
    Get.offAndToNamed(Routes.SIGN_IN);
  }

  void loadData() async {
    try {
      String url = "$baseUrl/initial/get_all_data";
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res["success"]) {
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
          courses.value = ((res["courses"] as List<dynamic>)
              .map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
              .toList());
          semesters.value = ((res["semesters"] as List<dynamic>)
              .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
              .toList());
          route();
        } else {
          Get.snackbar("Error", "Couldn't Fetch Data from Server:");
        }
      } else {
        Get.snackbar("Error", "Server is Irresponsive");
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

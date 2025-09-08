// jsonEncode calls moved into ApiClient

import 'package:app/app/core/network/endpoints.dart';
import 'package:app/app/core/network/api_client.dart';
import 'package:app/app/dashboard/controllers/teacher_dashboard_controller.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:get/get.dart';
// no direct http usage after refactor

// Local Imports
import '../../models/course_model.dart';
import '../../models/semester_model.dart';
import '../../models/department_model.dart';
import '../../models/program_model.dart';
import '../../models/faculty_model.dart';
import '../../loading/controllers/loading_controller.dart';

/// Controller for adding teacher courses based on selected faculty/department/program/semester.
class AddCoursesController extends GetxController {
  late LoadingController controller;
  late final ApiClient _apiClient;
  // 1. Faculty
  RxList<FacultyModel> faculities = <FacultyModel>[].obs;
  RxList<FacultyModel> selectedFaculties = <FacultyModel>[].obs;
  // 2. Departments
  RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  RxList<DepartmentModel> dropDownDepartmentOptions = <DepartmentModel>[].obs;
  RxList<DepartmentModel> selectedDepartments = <DepartmentModel>[].obs;
  // Programs
  RxList<ProgramModel> programs = <ProgramModel>[].obs;
  RxList<ProgramModel> dropDownProgramsOptions = <ProgramModel>[].obs;
  RxList<ProgramModel> selectedPrograms = <ProgramModel>[].obs;
  // Semesters
  RxList<SemesterModel> semesters = <SemesterModel>[].obs;
  RxList<SemesterModel> dropDownSemesterOptions = <SemesterModel>[].obs;
  RxList<SemesterModel> selectedSemesters = <SemesterModel>[].obs;
  // Courses
  RxList<CourseModel> courses = <CourseModel>[].obs;
  RxList<CourseModel> dropDownCourseOptions = <CourseModel>[].obs;
  RxList<CourseModel> selectedCourses = <CourseModel>[].obs;

  // Utility Functions
  void changeDepartments() {
    dropDownDepartmentOptions.value = (departments.where(
      (m2) => selectedFaculties.any((m1) => m1.factId == m2.factId),
    )).toList();
    // Select Programs as first index programs:
    // if (selectedDepartments.isNotEmpty) {
    //   selectedPrograms.value = programs
    //       .where((e) => e.deptId == selectedDepartments[0].deptId)
    //       .toList();
    //   if (selectedPrograms.isNotEmpty) {
    //     selectedSemesters.value = semesters
    //         .where((e) => e.progId == selectedPrograms[0].progId)
    //         .toList();
    //     if (selectedSemesters.isNotEmpty) {
    //       selectedCourses.value = courses
    //           .where((e) => e.semId == selectedSemesters[0].semId)
    //           .toList();
    //     } else {
    //       selectedCourses.value = [];
    //     }
    //   } else {
    //     selectedSemesters.value = [];
    //     selectedCourses.value = [];
    //   }
    // } else {
    //   selectedPrograms.value = [];
    //   selectedSemesters.value = [];
    //   selectedCourses.value = [];
    // }
  }

  void changePrograms() {
    dropDownProgramsOptions.value = (programs.where(
      (m2) => selectedDepartments.any((m1) => m1.deptId == m2.deptId),
    )).toList();
  }

  void changeSemester() {
    dropDownSemesterOptions.value = (semesters.where(
      (m2) => selectedPrograms.any((m1) => m1.progId == m2.progId),
    )).toList();
  }

  void changeCourse() {
    dropDownCourseOptions.value = (courses.where(
      (m2) => selectedSemesters.any((m1) => m1.semId == m2.semId),
    )).toList();
  }

  /// Adds the selected courses for the current teacher.
  void addCourses() async {
    final TeacherDashboardController dashboardController =
        Get.find<TeacherDashboardController>();
    final courses = selectedCourses.map((e) => e.toJson()).toList();
    var coursesToAdd = [];
    for (var course in courses) {
      coursesToAdd.add({
        "teacher_id":
            dashboardController.singInController.teacherData.value.teacherId,
        ...course,
      });
    }
    var body = {"courses": coursesToAdd};
    try {
      final res = await _apiClient.postJson(
        "${Endpoints.baseUrl}/teacher_course/add_all_teacher_courses",
        body,
      );
      if (res["success"] == true) {
          dashboardController.loadTeacherCourses();
          Get.snackbar(
            "SUCCESS",
            "Courses Added Successfully",
            colorText: Colors.green,
          );
      } else {
        Get.snackbar(
          "ERROR",
          "Something went wrong ${res["message"]}",
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar("ERROR", "Something went wrong $e", colorText: Colors.red);
    }
  }

  void clear() {
    selectedFaculties.clear();
    selectedDepartments.clear();
    dropDownDepartmentOptions.clear();
    selectedPrograms.clear();
    dropDownProgramsOptions.clear();
    selectedSemesters.clear();
    dropDownSemesterOptions.clear();
    selectedCourses.clear();
    dropDownCourseOptions.clear();
  }

  // Start Up Functions
  void start() {
    controller = Get.find<LoadingController>();
    // Getting Initial Data:
    faculities = controller.faculities;
    departments = controller.departments;
    programs = controller.programs;
    courses = controller.courses;
    semesters = controller.semesters;
  }

  @override
  void onInit() {
    super.onInit();
    print("In init ${selectedFaculties}");
    start();
  _apiClient = ApiClient();
  }
}

import 'dart:convert';

import 'package:app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// Local Imports::
import '../../signin/models/teacher_model.dart';
import '../../signin/controllers/signin_controller.dart';
import '../../constants/network_constants.dart';
import '../models/register_model.dart';
import '../../models/department_model.dart';
import '../../models/faculty_model.dart';
import '../../loading/controllers/loading_controller.dart';

class RegisterController extends GetxController {
  Rx<RegisterModel> registrationData = RegisterModel(
    teacherId: "",
    teacherName: '',
    type: '',
    deptId: '',
  ).obs;
  // Faculties;
  RxList<FacultyModel> faculties = <FacultyModel>[].obs;
  Rx<FacultyModel> selectedFaculty = FacultyModel(factId: "", factName: "").obs;
  // Departments:
  RxList<DepartmentModel> departments = <DepartmentModel>[].obs;
  RxList<DepartmentModel> dropDownSelectedDepartments = <DepartmentModel>[].obs;
  Rx<DepartmentModel> selectedDepartment = DepartmentModel(
    deptId: "",
    deptName: "",
    factId: "",
  ).obs;

  // Teacher type:
  RxList teacherType = ["PERMANENT", "CONTRACT", "GUEST"].obs;
  RxString teacherTypeSelected = "PERMANENT".obs;

  // Name:
  final nameController = TextEditingController();
  final teacherNameError = RxnString();

  // Teacher Data:
  RxMap teacherData = {}.obs;

  // Utility Functions:
  void changeDropDownSelectedDepartments() {
    dropDownSelectedDepartments.value = departments
        .where((e) => e.factId == selectedFaculty.value.factId)
        .toList();
    if (dropDownSelectedDepartments.isNotEmpty) {
      selectedDepartment.value = dropDownSelectedDepartments[0];
    } else {
      selectedDepartment.value = DepartmentModel(
        deptId: "",
        deptName: "",
        factId: "",
      );
    }
  }

  void validateTeacherName(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      teacherNameError.value = 'Name cannot be empty';
    } else if (trimmed.length < 3) {
      teacherNameError.value = 'Must be at least 3 characters';
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(trimmed)) {
      teacherNameError.value = 'Only letters and spaces allowed';
    } else {
      teacherNameError.value = null;
    }
  }

  void registerTeacher() async {
    final SignInController signInController = Get.find<SignInController>();
    final email = signInController.emailController.value.text;
    final factId = selectedFaculty.value.factId;
    final deptId = selectedDepartment.value.deptId;
    final teacherName = nameController.value.text;
    if (email.isEmpty ||
        teacherName.isEmpty ||
        teacherType.isEmpty ||
        deptId.isEmpty ||
        factId.isEmpty) {
      Get.snackbar("Error", "Please Add all fields!", colorText: Colors.red);
      return;
    }
    teacherData.value = {
      "teacher_id": email,
      "teacher_name": teacherName,
      "type": teacherTypeSelected.value,
      "dept_id": deptId,
      "fact_id": factId,
    };
    try {
      var url = "$baseUrl/authenticate/register_teacher";
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(teacherData),
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res["success"]) {
          // Go to Dashboard:
          signInController.teacherData.value = TeacherModel.fromJson(res);
          Get.offAllNamed(Routes.TEACHER_DASHBOARD);
        } else {
          Get.snackbar("Error", res["message"], colorText: Colors.red);
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "$e", colorText: Colors.red);
    }
  }

  void loadData() {
    final LoadingController loadingController = Get.find<LoadingController>();
    faculties.value = loadingController.faculities;

    departments.value = loadingController.departments;
    if (faculties.isNotEmpty) {
      selectedFaculty.value = faculties[0];
      changeDropDownSelectedDepartments();
      if (dropDownSelectedDepartments.isNotEmpty) {
        selectedDepartment.value = dropDownSelectedDepartments[0];
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}

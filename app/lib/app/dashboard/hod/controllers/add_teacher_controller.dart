import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/enums/teacher_type.dart';
import '../../../signin/controllers/signin_controller.dart';

class AddTeacherController extends GetxController {
  var emailController = TextEditingController().obs;
  var nameController = TextEditingController().obs;
  var teacherType = TeacherType.allValues.obs;
  var selectedTeacherType = ''.obs;
  final SignInController signInController = Get.find<SignInController>();


  final ApiClient client = ApiClient();


  void clearFields() {
    emailController.value.clear();
    nameController.value.clear();
    selectedTeacherType.value = teacherType.first;
    
  }



  Future<bool> addTeacher() async {
    // Implement the logic to add a teacher using the API client
    final id = emailController.value.text;
    final name = nameController.value.text;
    final type = selectedTeacherType.value;

    if (id.isEmpty || name.isEmpty || type.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return false;
    }
    try {
      final response = await client.postJson(Endpoints.addTeacher, {
        'teacher_id': id,
        'teacher_name': name,
        'type': type,
        'dept_id': signInController.userData.value.deptId,
      });
      if (response['success'] == true) {
        Get.snackbar("Success", "Teacher added successfully");
        return true; 
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed to add teacher");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
    return false; 
  }

  
  @override
  void onInit() {
    super.onInit();
    selectedTeacherType.value = teacherType.first;
  }

}
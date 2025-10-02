


import 'package:app/app/core/core.dart';
import 'package:get/get.dart';

class EditTeacherController  extends GetxController{
  var teacherId = ''.obs;
  var teacherName = ''.obs;
  var teacherType = TeacherType.allValues.obs;
  var selectedTeacherType = ''.obs;

  final ApiClient client = ApiClient();


  void updateData({required String id, required String name, required String type}) {
    teacherName.value = name;
    selectedTeacherType.value = type;
    teacherId.value = id;
  }


  Future<bool> updateTeacher(String previousTeacherid) async {
    final id = teacherId.value;
    final name = teacherName.value;
    final type = selectedTeacherType.value;

    if (id.isEmpty || name.isEmpty || type.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return false;
    }
    try {
      print("Updating Teacher: $previousTeacherid to $id, $name, $type");
      final response = await client.postJson(Endpoints.editTeacher, {
        "previous_teacher_id": previousTeacherid,
        'details': {
          'teacher_id': id,
          'teacher_name': name,
          'type': type,
        },
      });
      if (response['success'] == true) {
        Get.snackbar("Success", "Teacher updated successfully");
        return true; 
      } else {
        Get.snackbar("Error", response['message'] ?? "Failed to update teacher");
      }
    } catch (e) {
      print("Error updating teacher: $e");
      Get.snackbar("Error", "An error occurred: $e");
    }
    return false; 
  }




  void clearFields() {
    teacherId.value = '';
    teacherName.value = '';
    selectedTeacherType.value = teacherType.first;
  }

}
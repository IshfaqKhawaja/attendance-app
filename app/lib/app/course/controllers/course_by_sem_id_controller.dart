import 'dart:io';

import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// http not needed after refactor
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../../models/course_model.dart';
import '../../models/student_model.dart';
import '../../signin/models/teacher_model.dart';

class CourseBySemesterIdController  extends GetxController{
  var coursesBySemesterId = <CourseModel>[].obs;
  var studentsInThisSem = <StudentInSemModel>[].obs;
  RxList<TeacherModel> teachersInThisDept = <TeacherModel>[].obs;
  var selectedTeacher = Rx<TeacherModel?>(null);
  // Course Form Controller
  final TextEditingController nameController = TextEditingController();
  final ApiClient client= ApiClient();
  final SignInController signInController = Get.find<SignInController>();

  void getCourseReport(String courseId, startDate, endDate) async  {
    try{
      final dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/course_report_$courseId${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final bytes = await client.postBytes(
        Endpoints.generateCourseReport,
        {
          'course_id': courseId,
          'start_date': startDate,
          'end_date': endDate,
          'file_path': filePath,
        },
      );


      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to generate report",
        colorText: Colors.red,
      );
    }
  }

  // Function to get start data and end date for course report generation
  void showReportDatePicker(BuildContext context, String courseId) async  {
    DateTime? startDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().subtract(Duration(days: 7)),
    firstDate: DateTime(2022),
    lastDate: DateTime.now(),
    helpText: "Start Date",
  );

  if (startDate == null) return;

  DateTime? endDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: startDate,
    lastDate: DateTime.now(),
    helpText: "End Date",
  );

  if (endDate == null) return;

  // Confirm dialog
  Get.dialog(
    AlertDialog(
      title: Text("Generate Report"),
      content: Text("Do you want to generate report from ${startDate.day}/${startDate.month}/${startDate.year} to ${endDate.day}/${endDate.month}/${endDate.year}?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Get.back(); // close the dialog
            getCourseReport(courseId, startDate.toIso8601String(), endDate.toIso8601String());},
          child: Text("Generate"),
        ),
      ],
    ),
  );
  }

  // Add Course Function
  void addCourse(String name, String semId) async {
      try{
        var res = await client.postJson(
          Endpoints.addCourse,
          {
            "course_name": name,
            "sem_id": semId,
          },
        );
        if(res["success"] == true){
          Get.snackbar("Success", "Course Added Successfully",
            colorText: Colors.green,
          );
          getCoursesBySemesterId(semId);
        } else {
          Get.snackbar("Error", res["message"] ?? "Failed to add course",
            colorText: Colors.red,
          );
        }
      }catch(e){
        print(e);
        Get.snackbar("Error", "Failed to add course",
          colorText: Colors.red,
        );
      }
  }






  void getCoursesBySemesterId(String semesterId) async {
    try {
      final res = await client.getJson(
          Endpoints.displayCoursesBySemesterId(semesterId));
      if (res['success'] == true) {
        coursesBySemesterId.value = (res['courses'] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to fetch courses');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch courses: $e');
    }
  }


Future<bool> deleteCourseById(String courseId, String semId) async {
    try {
      final res = await client.getJson(
        Endpoints.deleteCourseById(courseId)
      );
      if (res['success'] == true) {
        Get.snackbar('Success', 'Course Deleted Successfully',
          colorText: Colors.green,
        );
        getCoursesBySemesterId(semId);
        return true;
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to delete course',
          colorText: Colors.red,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete course: $e',
        colorText: Colors.red,
      );
      return false;
    }
  }

Future<void> selectAndUploadCSVFile(String semId) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.isEmpty){
      Get.snackbar('Error', 'No file selected');
      return;
    }
    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    // Upload the file
    final res = await client.uploadFile(
      Endpoints.addStudentsFromFile,
      file,
      fileName,
      {"sem_id": semId},
    );
    print(res);
    Get.snackbar('Success', 'File uploaded successfully',
      colorText: Colors.green,
    );
  } catch (e) {
    print(e);
    Get.snackbar('Error', 'Failed to upload file: $e',
      colorText: Colors.red,
    );
  }
}



void fetchStudentsInThisSem(String semId) async {
    studentsInThisSem.clear();
    try {
      var res = await client.getJson(
        Endpoints.getStudentsBySemId(semId),
      );
      if (res["success"] == true) {
        studentsInThisSem.value = (res["students"] as List)
            .map((e) => StudentInSemModel.fromJson(e))
            .toList();
      } else {
        print(res);
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to load students for semester');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to load students for semester: $e');
    }
  }


void fetchTeachersInThisDept() async {
    final deptIdRaw = signInController.userData.value.deptId;
    final String? deptId = deptIdRaw?.toString();
    if (deptId == null || deptId.isEmpty) {
      Get.snackbar('Error', 'Department id is not available');
      return;
    }
    try {
      var res = await client.getJson(
        Endpoints.getTeachersByDeptId(deptId),
      );
      debugPrint(res.toString());
      if (res["success"] == true) {
        final teachersList = (res["teachers"] as List)
            .map((e) => TeacherModel.fromJson(e))
            .toList();
        print(teachersList);
        teachersInThisDept.assignAll(teachersList);
        print(teachersInThisDept);
        debugPrint('teachers count: ${teachersInThisDept.length}');
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to load teachers for department');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to load teachers for department: $e');
    }
  }


 void clear(){
  nameController.clear();
  }


  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

}


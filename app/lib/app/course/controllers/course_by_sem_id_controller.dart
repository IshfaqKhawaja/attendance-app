import 'dart:async';
import 'dart:io';

import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// http not needed after refactor
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
      // Show loading indicator
      Get.snackbar("Please wait", "Generating report...",
        colorText: Colors.blue,
        duration: const Duration(seconds: 2),
      );

      // Use external storage for better file sharing with other apps
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      String filePath = "${dir.path}/course_report_$courseId${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final bytes = await client.postBytes(
        Endpoints.generateCourseReport,
        {
          'course_id': courseId,
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      if (bytes.isEmpty) {
        Get.snackbar("No Data", "No attendance records found for the selected date range. Please check if attendance has been marked.",
          colorText: Colors.orange,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Try to open the file, fallback to share if no app available
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        Get.snackbar("Success", "Report opened successfully",
          colorText: Colors.green,
        );
      } else {
        // Fallback: Use share to let user choose how to handle the file
        Get.snackbar("Info", "Opening share options. You can save or open the file with any spreadsheet app.",
          colorText: Colors.blue,
          duration: const Duration(seconds: 3),
        );
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Course Attendance Report',
        );
      }
    } on SocketException {
      Get.snackbar("Network Error", "Unable to connect to server. Please check your internet connection.",
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } on TimeoutException {
      Get.snackbar("Timeout", "Server took too long to respond. Please try again later.",
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint("Error generating course report: $e");
      String errorMessage = "Something went wrong while generating the report.";
      if (e.toString().contains("401")) {
        errorMessage = "Session expired. Please log in again.";
      } else if (e.toString().contains("404")) {
        errorMessage = "Course not found. It may have been deleted.";
      } else if (e.toString().contains("500")) {
        errorMessage = "Server error. Please try again later or contact support.";
      }
      Get.snackbar("Error", errorMessage,
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
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
        if(selectedTeacher.value == null){
          Get.snackbar("Error", "Please select a teacher",
            colorText: Colors.red,
          );
          return;
        }
        if(name.isEmpty){
          Get.snackbar("Error", "Please enter course name",
            colorText: Colors.red,
          );
          return;
        }
        var res = await client.postJson(
          Endpoints.addCourse,
          {
            "course_name": name,
            "sem_id": semId,
            "assigned_teacher_id": selectedTeacher.value?.teacherId,
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

  // Edit Course Function
  void editCourse(String courseId, String name, String semId) async {
      try{
        if(selectedTeacher.value == null){
          Get.snackbar("Error", "Please select a teacher",
            colorText: Colors.red,
          );
          return;
        }
        if(name.isEmpty){
          Get.snackbar("Error", "Please enter course name",
            colorText: Colors.red,
          );
          return;
        }
        var res = await client.postJson(
          Endpoints.editCourse,
          {
            "course_id": courseId,
            "course_name": name,
            "assigned_teacher_id": selectedTeacher.value?.teacherId,
          },
        );
        if(res["success"] == true){
          Get.snackbar("Success", "Course Updated Successfully",
            colorText: Colors.green,
          );
          getCoursesBySemesterId(semId);
        } else {
          Get.snackbar("Error", res["message"] ?? "Failed to update course",
            colorText: Colors.red,
          );
        }
      }catch(e){
        print(e);
        Get.snackbar("Error", "Failed to update course",
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



Future<void> fetchStudentsInThisSem(String semId) async {
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
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to load students for semester');
      }
    } catch (e) {
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
      if (res["success"] == true) {
        final teachersList = (res["teachers"] as List)
            .map((e) => TeacherModel.fromJson(e))
            .toList();
        teachersInThisDept.assignAll(teachersList);
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to load teachers for department');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load teachers for department: $e');
    }
  }



void attendanceForSem(String semId) async {
    try {
      // Show loading indicator
      Get.snackbar("Please wait", "Generating semester report...",
        colorText: Colors.blue,
        duration: const Duration(seconds: 2),
      );

      // Use external storage for better file sharing with other apps
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      String filePath = "${dir.path}/attendance_report_$semId${DateTime.now().millisecondsSinceEpoch}.xlsx";
      final bytes = await client.postBytes(
        Endpoints.generateAttendanceReportBySemId,
        {
          'sem_id': semId,
        },
      );

      if (bytes.isEmpty) {
        Get.snackbar("No Data", "No attendance records found for this semester. Please check if attendance has been marked for any course.",
          colorText: Colors.orange,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Try to open the file, fallback to share if no app available
      final result = await OpenFile.open(filePath);
      if (result.type == ResultType.done) {
        Get.snackbar("Success", "Report opened successfully",
          colorText: Colors.green,
        );
      } else {
        // Fallback: Use share to let user choose how to handle the file
        Get.snackbar("Info", "Opening share options. You can save or open the file with any spreadsheet app.",
          colorText: Colors.blue,
          duration: const Duration(seconds: 3),
        );
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Semester Attendance Report',
        );
      }
    } on SocketException {
      Get.snackbar("Network Error", "Unable to connect to server. Please check your internet connection.",
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } on TimeoutException {
      Get.snackbar("Timeout", "Server took too long to respond. Please try again later.",
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint("Error generating semester report: $e");
      String errorMessage = "Something went wrong while generating the report.";
      if (e.toString().contains("401")) {
        errorMessage = "Session expired. Please log in again.";
      } else if (e.toString().contains("404")) {
        errorMessage = "Semester not found. It may have been deleted.";
      } else if (e.toString().contains("500")) {
        errorMessage = "Server error. Please try again later or contact support.";
      }
      Get.snackbar("Error", errorMessage,
        colorText: Colors.red,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> deleteStudentFromSem(String studentId, String semId) async {
    try {
      final res = await client.postJson(
        Endpoints.deleteStudentById,
        {
          'student_id': studentId,
          'sem_id': semId,
        },
      );
      if (res['success'] == true) {
        Get.snackbar('Success', 'Student removed from semester successfully',
          colorText: Colors.green,
        );
        await fetchStudentsInThisSem(semId);
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to remove student from semester',
          colorText: Colors.red,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove student from semester: $e',
        colorText: Colors.red,
      );
    }
  }

  // Add Student Function
  Future<void> addStudent(String studentId, String studentName, String phoneNumber, String semId) async {
    try {
      if (studentId.isEmpty) {
        Get.snackbar("Error", "Please enter student ID",
          colorText: Colors.red,
        );
        return;
      }
      if (studentName.isEmpty) {
        Get.snackbar("Error", "Please enter student name",
          colorText: Colors.red,
        );
        return;
      }
      if (phoneNumber.isEmpty) {
        Get.snackbar("Error", "Please enter phone number",
          colorText: Colors.red,
        );
        return;
      }

      // First add student to students table
      var res = await client.postJson(
        Endpoints.addStudent,
        {
          "student_id": studentId,
          "student_name": studentName,
          "phone_number": int.tryParse(phoneNumber) ?? 0,
          "sem_id": semId,
        },
      );

      if (res["success"] == true) {
        // Then add enrollment
        var enrollRes = await client.postJson(
          Endpoints.addStudentEnrollment,
          {
            "student_id": studentId,
            "sem_id": semId,
          },
        );

        if (enrollRes["success"] == true) {
          Get.snackbar("Success", "Student Added Successfully",
            colorText: Colors.green,
          );
          await fetchStudentsInThisSem(semId);
        } else {
          Get.snackbar("Error", enrollRes["message"] ?? "Failed to enroll student",
            colorText: Colors.red,
          );
        }
      } else {
        Get.snackbar("Error", res["message"] ?? "Failed to add student",
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to add student",
        colorText: Colors.red,
      );
    }
  }

  // Edit Student Function
  Future<void> editStudent(String studentId, String studentName, String phoneNumber, String semId) async {
    try {
      if (studentName.isEmpty) {
        Get.snackbar("Error", "Please enter student name",
          colorText: Colors.red,
        );
        return;
      }
      if (phoneNumber.isEmpty) {
        Get.snackbar("Error", "Please enter phone number",
          colorText: Colors.red,
        );
        return;
      }

      var res = await client.postJson(
        Endpoints.editStudent,
        {
          "student_id": studentId,
          "student_name": studentName,
          "phone_number": int.tryParse(phoneNumber) ?? 0,
        },
      );

      if (res["success"] == true) {
        Get.snackbar("Success", "Student Updated Successfully",
          colorText: Colors.green,
        );
        await fetchStudentsInThisSem(semId);
      } else {
        Get.snackbar("Error", res["message"] ?? "Failed to update student",
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to update student",
        colorText: Colors.red,
      );
    }
  }


 void clear(){
  nameController.clear();
  selectedTeacher.value = null;
  }


  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

}


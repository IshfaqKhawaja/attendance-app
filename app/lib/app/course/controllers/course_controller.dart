import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/student_model.dart';
import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/course_repository.dart';
import '../models/course_students_model.dart';
import '../models/student_attendence.dart';

class CourseController extends GetxController {
  CourseController({required this.courseId});
  var studentsInThisCourse = <StudentModel>[].obs;
  var studentsInThisSem = <StudentModel>[].obs;
  final String courseId;
  // New Data
  var newStudents = <StudentModel>[].obs;
  var newCourseStudents = <CourseStudentsModel>[].obs;

  // Attendence data:::
  var countedAs = 1.obs;
  var attendenceMarked = <StudentAttendance>[].obs;

  late final ApiClient _apiClient;
  late final CourseRepository _repo;


  void getStudentsList() async {
    studentsInThisCourse.clear();
    try {
      final res = await _repo.listStudentsByCourse(courseId);
      if (res["success"] == true) {
        studentsInThisCourse.value = (res["students"] as List)
            .map((e) => StudentModel.fromJson(e))
            .toList();
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to load students');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load students: $e');
    }
  }

  void addStudents() async {
    try {
      final res = await _repo.addStudentsToCourse(
        newStudents.map((e) => e.toJson()).toList(),
        newCourseStudents.map((e) => e.toJson()).toList(),
      );
      if (res['success'] == true) {
        Get.snackbar(
          'SUCCESS',
          'Students and Course Students Added',
          colorText: Colors.green,
        );
      } else {
        Get.snackbar('ERROR', res['message']?.toString() ?? 'Could not add students', colorText: Colors.red);
      }
    } catch (e) {
      Get.snackbar('ERROR', 'Could not add students: $e', colorText: Colors.red);
    } finally {
      getStudentsList();
    }
  }

  Future<void> pickCsvFile(course) async {
    newCourseStudents.clear();
    newStudents.clear();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        print("❌ No file selected.");
        return;
      }

      final file = result.files.single;
      Uint8List fileBytes;

      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else {
        print("❌ No valid file content.");
        return;
      }

      final content = String.fromCharCodes(fileBytes);
      final csvTable = const CsvToListConverter().convert(content);

      for (int i = 0; i < csvTable.length; i++) {
        newCourseStudents.add(
          CourseStudentsModel(
            studentId: csvTable[i][0],
            progId: course.progId,
            semId: course.semId,
            deptId: course.deptId,
            courseId: course.courseId,
          ),
        );
        newStudents.add(
          StudentModel(
            studentId: csvTable[i][0],
            studentName: csvTable[i][1],
            phoneNumber: csvTable[i][2],
            progId: course.progId,
            semId: course.semId,
            deptId: course.deptId,
          ),
        );
      }
      addStudents();
    } catch (e, st) {
      print("⚠️ Error reading CSV: $e\n$st");
    }
  }

  // Attendence :::

  void getStudentsForAttendence() {
    attendenceMarked.value = studentsInThisCourse.map((student) {
      return StudentAttendance(
        studentId: student.studentId,
        studentName: student.studentName,
        courseId: courseId,
        semId: student.semId,
        date: DateTime.now(),
        deptId: student.deptId,
        progId: student.progId,
        marked: List.generate(countedAs.value, (_) => false),
      );
    }).toList();
  }

  void addAttendence() async {
    try {
      var attendence = jsonEncode(
        attendenceMarked.map((e) => e.toJson()).toList(),
      );
      var response = await http.post(
        Uri.parse("${Endpoints.baseUrl}/attendance/add_attendence_bulk"),
        body: attendence,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res["success"]) {
          Get.snackbar("Success", res["message"], colorText: Colors.green);
        } else {
          Get.snackbar("ERROR", res["message"], colorText: Colors.red);
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar("ERROR", "$e", colorText: Colors.red);
    }
  }
 void showDateRangeDialog(BuildContext context) async {
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
            generateReport(startDate, endDate);
          },
          child: Text("Generate"),
        ),
      ],
    ),
  );
}

  Future<void> generateReport(DateTime startDate, DateTime endDate) async {
  try {
    final bytes = await _repo.generateCourseReport(
      courseId,
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    );

      // 📁 Get download directory
      final dir = await getApplicationDocumentsDirectory(); // For internal storage
      final filePath = "${dir.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
      // Get.snackbar("Success", "PDF saved to $filePath", colorText: Colors.green, snackPosition: SnackPosition.BOTTOM,
      //   duration: Duration(seconds: 5));
  } catch (e) {
    print(e);
    Get.snackbar("Error", "Something went wrong: $e", colorText: Colors.red);
  }
}





 
  @override
  void onInit() {
    super.onInit();
  _apiClient = ApiClient();
  _repo = CourseRepository(_apiClient);
    getStudentsList();
  }
}

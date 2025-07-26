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
import '../../constants/network_constants.dart';
import '../models/course_students_model.dart';
import '../models/student_attendence.dart';

class CourseController extends GetxController {
  var studentsInThisCourse = <StudentModel>[].obs;
  final String courseId;
  // New Data
  var newStudents = <StudentModel>[].obs;
  var newCourseStudents = <CourseStudentsModel>[].obs;

  // Attendence data:::
  var countedAs = 1.obs;
  var attendenceMarked = <StudentAttendance>[].obs;

  CourseController({required this.courseId});

  void getStudentsList() async {
    studentsInThisCourse.clear();
    var response = await http.post(
      Uri.parse("$baseUrl/course_students/display_students_by_ids"),
      body: jsonEncode({"course_id": courseId}),
      headers: {"Content-Type": "application/json"},
    );
    var res = jsonDecode(response.body);
    if (res["success"]) {
      studentsInThisCourse.value = (res["students"] as List)
          .map((e) => StudentModel.fromJson(e))
          .toList();
    }
  }

  void addStudents() async {
    var response = await http.post(
      Uri.parse("$baseUrl/course_students/add_students_to_course"),
      body: jsonEncode({
        "students": newStudents.map((e) => e.toJson()).toList(),
        "course_students": newCourseStudents.map((e) => e.toJson()).toList(),
      }),
      headers: {"Content-Type": "application/json"},
    );
    var res = jsonDecode(response.body);
    if (res["success"]) {
      Get.snackbar(
        "SUCCESS",
        "Students and Course Students Added",
        colorText: Colors.green,
      );
    } else {
      Get.snackbar("ERROR", res["message"], colorText: Colors.red);
    }
    getStudentsList();
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
        Uri.parse("$baseUrl/attendance/add_attendence_bulk"),
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
    var response = await http.post(
      Uri.parse("$baseUrl/course_students/generate_report"),
      body: jsonEncode({
        "course_id": courseId,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String()
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // 🔽 Save the PDF to device
      final bytes = response.bodyBytes;

      // 📁 Get download directory
      final dir = await getApplicationDocumentsDirectory(); // For internal storage
      final filePath = "${dir.path}/attendance_report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
      // Get.snackbar("Success", "PDF saved to $filePath", colorText: Colors.green, snackPosition: SnackPosition.BOTTOM,
      //   duration: Duration(seconds: 5));
    } else {
      Get.snackbar("Error", "Failed to generate report", colorText: Colors.red);
    }
  } catch (e) {
    print(e);
    Get.snackbar("Error", "Something went wrong: $e", colorText: Colors.red);
  }
}
  

  @override
  void onInit() {
    super.onInit();
    getStudentsList();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/student_model.dart';
import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/student_attendence.dart';

class CourseController extends GetxController {
  CourseController({required this.courseId});
  var studentsInThisCourse = <StudentModel>[].obs;
  var studentsInThisSem = <StudentModel>[].obs;
  final String courseId;
  // Attendence data:::
  var countedAs = 1.obs;
  var attendenceMarked = <StudentAttendanceList>[].obs;

  final ApiClient client = ApiClient();


  void getStudentsList() async {
    studentsInThisCourse.clear();
    try {
      final res = await client.getJson(Endpoints.getStudentsByCourseId(courseId));
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
  // Attendence :::

  void getStudentsForAttendence() {
    attendenceMarked.value = studentsInThisCourse.map((student) {
      return StudentAttendanceList(
        studentId: student.studentId,
        studentName: student.studentName,
        courseId: courseId,
        date: DateTime.now(),
        marked: List.generate(countedAs.value, (_) => false),
      );
    }).toList();
  }


  // Prepare attendance data for submission
  // making list of maps
  List<StudentAttendance> prepareAttendenceData() {
    var list = <StudentAttendance>[];
    for (var attendance in attendenceMarked) {
      for (int i = 0; i < countedAs.value; i++) {
        list.add(StudentAttendance(
          studentId: attendance.studentId,
          studentName: attendance.studentName,
          courseId: attendance.courseId,
          date: attendance.date,
          present: attendance.marked[i],
        ));
      }
    }
    return list;
  }


  void addAttendence() async {
    try {
  
      var res = await client.postJson(Endpoints.addAttendanceBulk,{
        'attendances': prepareAttendenceData().map((e) => e.toJson()).toList(),
      });
      print(res);
      if (res["success"]) {
        Get.snackbar("Success", res["message"], colorText: Colors.green);
      } else {
          Get.snackbar("ERROR", res["message"], colorText: Colors.red);
        }
    } catch (e) {
      print(e);
      Get.snackbar("ERROR", "$e", colorText: Colors.red);
    }
  }



 void showDateRangeDialog(BuildContext context, String courseName) async {
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
            generateReport(courseName, startDate, endDate);
          },
          child: Text("Generate"),
        ),
      ],
    ),
  );
}

  Future<void> generateReport(String courseName, DateTime startDate, DateTime endDate) async {
  try {
    

    final bytes = await client.postBytes(
      Endpoints.generateAttendanceReport,
      {
        'course_name': courseName,
        'course_id': courseId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
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


void clear() {
  studentsInThisCourse.clear();
  attendenceMarked.clear();
  countedAs.value = 1;
}

void clearAttendence() {
  attendenceMarked.clear();
  countedAs.value = 1;
}

}
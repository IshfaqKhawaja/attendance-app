



import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/network_constants.dart';
import '../../models/course_model.dart';

class CourseBySemesterIdController  extends GetxController{
  var coursesBySemesterId = <CourseModel>[].obs;
  // Course Form Controller
  final TextEditingController nameController = TextEditingController();

  void getCourseReport(String courseId, startDate, endDate) async  {
    try{
      final dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/course_report_$courseId${DateTime.now().millisecondsSinceEpoch}.xlsx";

     var response = await  http.post(
      Uri.parse("$baseUrl/reports/generate_course_report"),
      body: jsonEncode({
        "course_id": courseId, 
        "start_date": startDate, 
        "end_date": endDate,
        "file_path": filePath
        }),
      headers: {"Content-Type": "application/json"},
    );
      if (response.statusCode == 200) {
          // 🔽 Save the Excel to device
          final bytes = response.bodyBytes;
          final file = File(filePath);
          await file.writeAsBytes(bytes);
          await OpenFile.open(filePath);
      }
      else {
        Get.snackbar("Error", "Failed to generate report",
          colorText: Colors.red,
        );
      }
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
    try {
      var response = await http.post(
        Uri.parse("$baseUrl/course/add"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "sem_id": semId,
        }),
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}");
        Get.snackbar("Success", "Course added successfully",
          colorText: Colors.green,
        );
      } else {
        Get.snackbar("Error", "Failed to add course",
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to add course",
        colorText: Colors.red,
      );
    }
  }






  void getCoursesBySemesterId(String semesterId) async {
    var response = await http.get(
      Uri.parse("$baseUrl/course/display_courses_by_semester_id/$semesterId"),
    );

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res["success"]) {
        coursesBySemesterId.value = (res["courses"] as List)
            .map((e) => CourseModel.fromJson(e))
            .toList();
      }
    }
  }

}


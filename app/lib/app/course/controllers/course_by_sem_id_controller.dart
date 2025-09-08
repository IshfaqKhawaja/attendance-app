



import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// http not needed after refactor
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/course_repository.dart';
import '../../models/course_model.dart';

class CourseBySemesterIdController  extends GetxController{
  var coursesBySemesterId = <CourseModel>[].obs;
  // Course Form Controller
  final TextEditingController nameController = TextEditingController();
  late final ApiClient _apiClient;
  late final CourseRepository _repo;

  void getCourseReport(String courseId, startDate, endDate) async  {
    try{
      final dir = await getApplicationDocumentsDirectory();
      String filePath = "${dir.path}/course_report_$courseId${DateTime.now().millisecondsSinceEpoch}.xlsx";

      final bytes = await _repo.generateCourseReportXlsx(
        courseId,
        startDate,
        endDate,
        filePath,
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
    try {
      final res = await _repo.addCourse(name, semId);
      if (res['success'] == true) {
        Get.snackbar('Success', 'Course added successfully', colorText: Colors.green);
      } else {
        Get.snackbar('Error', res['message']?.toString() ?? 'Failed to add course', colorText: Colors.red);
      }
    } catch (e) {
      print(e);
      Get.snackbar("Error", "Failed to add course",
        colorText: Colors.red,
      );
    }
  }






  void getCoursesBySemesterId(String semesterId) async {
    try {
      final res = await ApiClient().getJson(
          "${Endpoints.baseUrl}/course/display_courses_by_semester_id/$semesterId");
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

  @override
  void onInit() {
    super.onInit();
    _apiClient = ApiClient();
    _repo = CourseRepository(_apiClient);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

}


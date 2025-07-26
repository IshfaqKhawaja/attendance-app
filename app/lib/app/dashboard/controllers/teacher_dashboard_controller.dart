import 'dart:convert';

import 'package:app/app/constants/network_constants.dart';
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:app/app/models/teacher_course.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TeacherDashboardController extends GetxController {
  final singInController = Get.find<SignInController>();
  final loadingController = Get.find<LoadingController>();
  final isTeacherCoursesLoaded = false.obs;
  RxList<TeacherCourseModel> thisTeacherCourses = <TeacherCourseModel>[].obs;

  void loadTeacherCourses() async {
    isTeacherCoursesLoaded.value = false;
    final url = Uri.parse("$baseUrl/teacher_course/display");
    final body = jsonEncode({
      "teacher_id": singInController.teacherData.value.teacherId,
    });
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res["success"]) {
        thisTeacherCourses.value = (res["teacher_courses"] as List<dynamic>)
            .map((e) => TeacherCourseModel.fromJson(e))
            .toList();
      }
    }
    isTeacherCoursesLoaded.value = true;
  }

  void attendanceNotifier() async {
    var response = await http.get(
      Uri.parse("$baseUrl/attendance_notifier/notify"),
    );

    try {
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        print(res);
      } else {
        Get.snackbar("ERROR", "Error Sending SMS");
      }
    } catch (e) {
      print(e);
      Get.snackbar("ERROR", "Error Sending SMS");
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadTeacherCourses();
  }
}

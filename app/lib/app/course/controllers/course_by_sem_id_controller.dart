



import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../constants/network_constants.dart';
import '../../models/course_model.dart';

class CourseBySemesterIdController  extends GetxController{
  var coursesBySemesterId = <CourseModel>[].obs;



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
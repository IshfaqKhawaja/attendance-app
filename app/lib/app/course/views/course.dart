import 'package:app/app/course/widgets/tab_bar_widget.dart';
import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'attendence.dart';
import 'students.dart';

class Course extends StatelessWidget {
  Course({super.key});
  final TeacherCourseModel course = Get.arguments["course"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Get.theme.primaryColor, Get.theme.primaryColorLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.085,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Course Info",
                style: GoogleFonts.openSans(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.13,
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                "Course Name: ${course.courseName}\nCourse ID : ${course.courseId}\nSem ID : ${course.semName}\nDept Name: ${course.deptName}\nFaculty : ${course.factName}",
                style: GoogleFonts.openSans(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.25,
            child: Container(
              height: Get.size.height * 0.01,
              width: Get.size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            top: Get.size.height * 0.26,
            child: Container(
              height: Get.size.height * 0.739,
              width: Get.size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(),
              ),
              child: TabBarWidget(
                tabs: [
                  Students(course: course),
                  Attendence(course: course),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

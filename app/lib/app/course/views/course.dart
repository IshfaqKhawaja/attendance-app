import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/typography.dart';
import '../../core/widgets/dashboard_scaffold.dart';
import '../../routes/app_routes.dart';
import '../controllers/course_controller.dart';
import 'attendence.dart';

class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final TeacherCourseModel course = Get.arguments["course"];

  late CourseController courseController;

  void loadStudentsData() async {
    await courseController.getStudentsList();
    await courseController.getStudentsForAttendence();
  }

  @override
  void initState() {
    super.initState();
    // Use course.courseId as a unique tag to create separate controller instances for each course
    courseController = Get.put(
      CourseController(courseId: course.courseId),
      tag: course.courseId, // Each course gets its own controller instance
    );
    loadStudentsData();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      headerContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  "Course Info",
                  style: GoogleFonts.openSans(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    child: Text(
                      "Students",
                      style: textStyle.copyWith(fontSize: 13),
                    ),
                    onPressed: () {
                      Get.toNamed(Routes.STUDENTS, arguments: {"course": course});
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      courseController.showDateRangeDialog(
                          context, course.courseName!);
                    },
                    child: Text(
                      "Report",
                      style: textStyle.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Course Name: ${course.courseName}\nCourse ID : ${course.courseId}\nSem ID : ${course.semName}",
            style: GoogleFonts.openSans(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
      bodyContent: Attendence(courseId: course.courseId),
    );
  }
}

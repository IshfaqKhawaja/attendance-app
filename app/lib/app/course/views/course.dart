import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/dashboard_scaffold.dart';
import '../../routes/app_routes.dart';
import '../controllers/course_controller.dart';
import '../widgets/attendance_history_dialog.dart';
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
                  IconButton(
                    icon: const Icon(Icons.people, color: Colors.white),
                    tooltip: 'View Students',
                    onPressed: () {
                      Get.toNamed(Routes.STUDENTS, arguments: {"course": course});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    tooltip: 'Attendance History',
                    onPressed: () {
                      AttendanceHistoryDialog.show(
                        context: context,
                        courseId: course.courseId,
                        courseName: course.courseName!,
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    tooltip: 'Generate Report',
                    onPressed: () {
                      courseController.showDateRangeDialog(
                          context, course.courseName!);
                    },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          courseController.addAttendence();
        },
        backgroundColor: Get.theme.primaryColor,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}

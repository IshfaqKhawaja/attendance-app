import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/course/widgets/student_widget.dart';
import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  late final CourseController courseController;

  @override
  void initState() {
    super.initState();
    // Get the course from route arguments
    final args = Get.arguments as Map<String, dynamic>;
    final TeacherCourseModel course = args['course'];
    
    // Find the controller with the tag
    courseController = Get.find<CourseController>(tag: course.courseId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Students In this Course", style: textStyle.copyWith(fontSize: 16, color: Colors.white),),
        backgroundColor: Get.theme.primaryColor,
      ),
      body: Stack(
        children: [
          Obx(() {
            final students = courseController.studentsInThisCourse;
            return ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: students.length,
              itemBuilder: (_, index) {
                if (students.isEmpty) {
                  return Center(
                    child: Text(
                      "No Students Found In this Course",
                      style: textStyle.copyWith(fontSize: 16),
                    ),
                  );
                }     
                index = index;
                return StudentWidget(student: students[index]);
              },
            );
          }),
        ],
      ),
    );
  }
}

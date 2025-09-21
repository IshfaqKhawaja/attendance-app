import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/course/widgets/student_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';

class Students extends StatefulWidget {
  // final TeacherCourseModel course;
  late final CourseController courseController;

  Students({super.key}) {
    courseController = Get.find<CourseController>();
  }

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  @override
  void initState() {
    super.initState();
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
            final students = widget.courseController.studentsInThisCourse;
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

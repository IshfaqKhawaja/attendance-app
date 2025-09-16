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
    widget.courseController.getStudentsList();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          final students = widget.courseController.studentsInThisCourse;
          return ListView.builder(
            itemCount: students.length + 1,
            itemBuilder: (_, index) {
              if (students.isEmpty) {
                return Center(
                  child: Text(
                    "No Students Found In this Course",
                    style: textStyle.copyWith(fontSize: 16),
                  ),
                );
              }
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Students In this Course", style: textStyle),
                );
              }

              index = index - 1;
              return StudentWidget(student: students[index]);
            },
          );
        }),

        // // FAB Overlay
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: FloatingActionButton(
        //     onPressed: () => courseController.pickCsvFile(course),
        //     child: Icon(Icons.upload_file),
        //   ),
        // ),
      ],
    );
  }
}

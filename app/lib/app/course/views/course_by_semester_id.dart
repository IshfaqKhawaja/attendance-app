import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_by_sem_id_controller.dart';
import '../widgets/add_course.dart';

class CourseBySemesterId extends StatefulWidget {
  const CourseBySemesterId({super.key});

  @override
  State<CourseBySemesterId> createState() => _CourseBySemesterIdState();
}

class _CourseBySemesterIdState extends State<CourseBySemesterId> {
  final String semesterId = Get.arguments['semesterId'] ?? '';

  final CourseBySemesterIdController courseController = Get.put(
    CourseBySemesterIdController(),
  );

  @override
  void initState() {
    super.initState();
    courseController.getCoursesBySemesterId(semesterId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses for Semester"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Get.dialog(
                barrierDismissible: true,
                Dialog(
                  child: AddCourse(
                    semesterId: semesterId,

                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (courseController.coursesBySemesterId.isEmpty) {
          return Center(child:Text("No courses found for this semester.", style: TextStyle(fontSize: 18)));
        }
        return ListView.builder(
          itemCount: courseController.coursesBySemesterId.length,
          itemBuilder: (context, index) {
            final course = courseController.coursesBySemesterId[index];
            return ListTile(
              title: Text(course.courseName, style: textStyle.copyWith(fontSize: 16)),
              subtitle: Text("Course ID: ${course.courseId}", style: textStyle.copyWith(fontSize: 14)),
              trailing: ElevatedButton(onPressed: (){
                courseController.showReportDatePicker(context, course.courseId);
              }, child: Text("Generate Report", style: textStyle.copyWith(fontSize: 12,),), ),
            );
          },
        );
      }),
    );
  }
}
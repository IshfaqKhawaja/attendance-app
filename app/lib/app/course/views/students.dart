import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/course/widgets/add_student_to_course.dart';
import 'package:app/app/course/widgets/edit_student_in_course.dart';
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
  late final String semId;
  late final String courseId;

  @override
  void initState() {
    super.initState();
    // Get the course from route arguments
    final args = Get.arguments as Map<String, dynamic>;
    final TeacherCourseModel course = args['course'];
    semId = course.semId;
    courseId = course.courseId;

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
      body: Column(
        children: [
          // Add Student Button at the top
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.dialog(
                  Dialog(
                    child: AddStudentToCourse(semesterId: semId, courseId: courseId),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add Student'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ),
          // Student List
          Expanded(
            child: Obx(() {
              if (courseController.studentsInThisCourse.isEmpty) {
                return Center(
                  child: Text(
                    "No Students Found In this Course",
                    style: textStyle.copyWith(fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                itemCount: courseController.studentsInThisCourse.length,
                itemBuilder: (context, index) {
                  final student = courseController.studentsInThisCourse[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('S${index + 1}'),
                    ),
                    title: Text(student.studentName),
                    subtitle: Text(student.studentId),
                    trailing: IntrinsicWidth(
                      child: Row(
                        children: [
                          // Edit button
                          IconButton(
                            onPressed: () {
                              Get.dialog(
                                Dialog(
                                  child: EditStudentInCourse(
                                    semesterId: semId,
                                    courseId: courseId,
                                    student: student,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.edit, size: 20, color: Get.theme.colorScheme.primary),
                          ),
                          // Delete button
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Remove Student", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    content: Text("Are you sure you want to remove '${student.studentName}' from this course?", style: TextStyle(fontSize: 14)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Get.back();
                                          await courseController.deleteStudentFromCourse(student.studentId, semId);
                                        },
                                        child: Text("Remove", style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

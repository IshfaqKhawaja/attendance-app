import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/course/widgets/add_student_to_course.dart';
import 'package:app/app/course/widgets/edit_student_in_course.dart';
import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';
import '../../core/utils/responsive_utils.dart';

class Students extends StatefulWidget {
  const Students({super.key});

  @override
  State<Students> createState() => _StudentsState();
}

class _StudentsState extends State<Students> {
  late final CourseController courseController;
  late final String semId;
  late final String courseId;

  // Max width for list items on web
  static const double maxItemWidth = 600;
  // Max width for dialogs on web
  static const double maxDialogWidth = 400;

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
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final crossAxisCount = ResponsiveUtils.value(
      context: context,
      mobile: 1,
      tablet: 2,
      desktop: 2,
      largeDesktop: 3,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text("Students In this Course", style: textStyle.copyWith(fontSize: 16, color: Colors.white),),
        backgroundColor: Get.theme.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 8),
        child: Column(
          children: [
            // Add Student Button at the top
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: kIsWeb ? maxItemWidth : double.infinity),
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
            ),
            const SizedBox(height: 8),
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

                // Use grid on larger screens
                if (kIsWeb && crossAxisCount > 1) {
                  return GridView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: courseController.studentsInThisCourse.length,
                    itemBuilder: (context, index) {
                      final student = courseController.studentsInThisCourse[index];
                      return _buildStudentCard(context, student, index);
                    },
                  );
                }

                // Use list on mobile or single column
                return ListView.builder(
                  itemCount: courseController.studentsInThisCourse.length,
                  itemBuilder: (context, index) {
                    final student = courseController.studentsInThisCourse[index];
                    // Constrain width on web even for list view
                    if (kIsWeb) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxItemWidth),
                          child: _buildStudentCard(context, student, index),
                        ),
                      );
                    }
                    return _buildStudentCard(context, student, index);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, dynamic student, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('S${index + 1}'),
        ),
        title: Text(student.studentName),
        subtitle: Text(student.studentId),
        trailing: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                        contentPadding: EdgeInsets.zero,
                        content: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
                            minWidth: kIsWeb ? maxDialogWidth : 280,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text("Are you sure you want to remove '${student.studentName}' from this course?", style: TextStyle(fontSize: 14)),
                          ),
                        ),
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
      ),
    );
  }
}

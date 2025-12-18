import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../signin/models/teacher_model.dart';
import '../controllers/course_by_sem_id_controller.dart';
import '../../models/course_model.dart';

class EditCourse extends StatefulWidget {
  final String semesterId;
  final CourseModel course;
  const EditCourse({super.key, required this.semesterId, required this.course});

  @override
  State<EditCourse> createState() => _EditCourseState();
}

class _EditCourseState extends State<EditCourse> {
  final CourseBySemesterIdController courseController = Get.find<CourseBySemesterIdController>();

  // Max width for dialog on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with existing course data
    courseController.nameController.text = widget.course.courseName;

    // Fetch teachers and set selected teacher after frame is built
    courseController.fetchTeachersInThisDept();

    // Use a listener to set the selected teacher once teachers are loaded
    ever(courseController.teachersInThisDept, (teachers) {
      if (teachers.isNotEmpty && courseController.selectedTeacher.value == null) {
        final teacher = teachers.firstWhereOrNull(
          (t) => t.teacherId == widget.course.assignedTeacherId
        );
        if (teacher != null) {
          courseController.selectedTeacher.value = teacher;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: kIsWeb ? null : Get.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
        maxHeight: Get.height * 0.4,
      ),
      child: Form(
        child: ListView(
          children: [
            Text(
              'Edit Course',
              style: textStyle.copyWith(fontSize: 24),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: courseController.nameController,
            ),
            const SizedBox(height: 20),
            Obx(() {
              if (courseController.teachersInThisDept.isEmpty) {
                return Text("Loading teachers...", style: textStyle.copyWith(fontSize: 14, color: Colors.grey));
              }
              return DropdownButton<TeacherModel>(
                hint: Text("Assign Teacher"),
                value: courseController.selectedTeacher.value,
                items: courseController.teachersInThisDept.map((TeacherModel teacher) {
                  return DropdownMenuItem<TeacherModel>(
                    value: teacher,
                    child: Text(teacher.teacherName),
                  );
                }).toList(),
                onChanged: (TeacherModel? newValue) {
                  courseController.selectedTeacher.value = newValue;
                },
              );
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Get.theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                courseController.editCourse(
                  widget.course.courseId,
                  courseController.nameController.text,
                  widget.semesterId,
                );
                Get.back();
              },
              child: Text('Update Course', style: textStyle.copyWith(fontSize: 14, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}




import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../signin/models/teacher_model.dart';
import '../controllers/course_by_sem_id_controller.dart';

class AddCourse extends StatefulWidget {
  final String semesterId;
  const AddCourse({super.key, required this.semesterId});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final CourseBySemesterIdController courseController = Get.put(CourseBySemesterIdController());

  // Max width for dialog on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
    courseController.clear();
    courseController.fetchTeachersInThisDept();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16.0),
          width: kIsWeb ? null : Get.width * 0.9,
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
            maxHeight: Get.height * 0.5,
          ),
          child: Form(
            child: ListView(
              children: [
                Text(
                  'Add Course',
                  style: textStyle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Course ID *',
                    hintText: 'e.g., CS101, MATH201',
                  ),
                  controller: courseController.courseIdController,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Course Name *',
                    hintText: 'e.g., Introduction to Programming',
                  ),
                  controller: courseController.nameController,
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (courseController.teachersInThisDept.isEmpty) {
                    return Text("Loading teachers...", style: textStyle.copyWith(fontSize: 14, color: Colors.grey),);
                  }
                    return DropdownButton<TeacherModel>(
                      hint: Text("Assign Teacher"),
                      value: courseController.selectedTeacher.value,
                      items: courseController.teachersInThisDept.map((TeacherModel teacher) {
                        return DropdownMenuItem<TeacherModel>(
                          value: teacher,
                          child: Text(teacher.teacherName), // Assuming TeacherModel has a 'teacherName' property
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
                    final courseId = courseController.courseIdController.text.trim();
                    final courseName = courseController.nameController.text.trim();

                    // Validate before closing
                    if (courseId.isEmpty) {
                      Get.snackbar("Error", "Please enter course ID",
                        colorText: Colors.red,
                      );
                      return;
                    }
                    if (courseName.isEmpty) {
                      Get.snackbar("Error", "Please enter course name",
                        colorText: Colors.red,
                      );
                      return;
                    }
                    if (courseController.selectedTeacher.value == null) {
                      Get.snackbar("Error", "Please select a teacher",
                        colorText: Colors.red,
                      );
                      return;
                    }

                    courseController.addCourse(
                      courseId,
                      courseName,
                      widget.semesterId,
                    );
                    Get.back();
                  },
                  child:  Text('Add Course', style: textStyle.copyWith(fontSize: 14, color: Colors.white,),),
                ),
              ],
            ),
          ),
        
    );
  }
}
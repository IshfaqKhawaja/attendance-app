


import 'package:app/app/constants/text_styles.dart';
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
          height: Get.height * 0.3,
          width: Get.width,
          child: Form(
            child: ListView(
              children: [
                Text(
                  'Add Course',
                  style: textStyle.copyWith(fontSize: 24),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: courseController.nameController,
                ),
                const SizedBox(height: 20),
                Obx(() {
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
                    courseController.addCourse(
                      courseController.nameController.text,
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
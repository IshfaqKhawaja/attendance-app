


import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_by_sem_id_controller.dart';

class AddCourse extends StatelessWidget {
  final String semesterId;
  AddCourse({super.key, required this.semesterId});
  final CourseBySemesterIdController courseController = Get.find<CourseBySemesterIdController>();
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16.0),
          height: Get.height * 0.2,
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
                      semesterId,
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
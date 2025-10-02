import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/course/controllers/course_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropDownWidget extends StatelessWidget {
  final String courseId;
  
  DropDownWidget({super.key, required this.courseId});
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CourseController>(
      tag: courseId,
      builder: (courseController) {
        return Obx(() {
          return DropdownButton<int>(
            value: courseController.countedAs.value,
            items: [1, 2, 3].map((e) {
              return DropdownMenuItem<int>(
                value: e,
                child: Text(e.toString(), style: textStyle.copyWith(fontSize: 16)),
              );
            }).toList(),
            onChanged: (value) async  {
              if (value != null) {
                courseController.countedAs.value = value;
                await courseController.getStudentsForAttendence();
              }
            },
            borderRadius: BorderRadius.all(Radius.circular(10)),
            menuWidth: 40,
            style: textStyle,
          );
        });
      },
    );
  }
}

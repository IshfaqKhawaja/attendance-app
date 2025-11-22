import 'package:app/app/constants/text_styles.dart';
import 'package:app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/teacher_course.dart';

class CardWidget extends StatelessWidget {
  final TeacherCourseModel course;
  const CardWidget({super.key, required this.course});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.COURSE, arguments: {"course": course});
      },
      child: Card(
        color: Get.theme.primaryColor.withValues(alpha: 0.7),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course:
              Text(
                course.courseName!,
                style: textStyle.copyWith(color: Colors.white, fontSize: 20),
              ),
              // Sem Name
              Text(
                course.semName!,
                style: textStyle.copyWith(color: Colors.white, fontSize: 16),
              ),
              // Prog Name:
              Text(
                course.progName!,
                style: textStyle.copyWith(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'card_widget.dart';
import '../controllers/teacher_dashboard_controller.dart';

class HomeWidget extends StatelessWidget {
  HomeWidget({super.key});
  final TeacherDashboardController dashboardController =
      Get.find<TeacherDashboardController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView.builder(
        itemCount: dashboardController.thisTeacherCourses.length + 1,
        itemBuilder: (_, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Your Courses",
                style: GoogleFonts.openSansCondensed(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (!dashboardController.isTeacherCoursesLoaded.value) {
            return SizedBox.shrink();
          }
          index = index - 1;
          final d = dashboardController.thisTeacherCourses[index];
          return CardWidget(course: d);
        },
      );
    });
  }
}

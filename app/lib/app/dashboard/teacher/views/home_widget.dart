import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/card_widget.dart';
import '../controllers/teacher_dashboard_controller.dart';

class HomeWidget extends StatelessWidget {
  HomeWidget({super.key});
  final TeacherDashboardController dashboardController =
      Get.find<TeacherDashboardController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        onRefresh: () => dashboardController.refreshCourses(),
        color: Get.theme.primaryColor,
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 10),
          itemCount: dashboardController.teacherCourses.length + 2, // +2 for header and instruction
          itemBuilder: (_, index) {
            // Header
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Courses",
                      style: GoogleFonts.openSans(
                        fontSize: 26,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Instruction box for older users
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.blue.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Tap on any course below to mark attendance",
                              style: GoogleFonts.openSans(
                                fontSize: 15,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Empty state message
            if (index == 1 && dashboardController.teacherCourses.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        "No courses assigned yet",
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!dashboardController.isCoursesLoaded.value) {
              return SizedBox.shrink();
            }

            // Adjust index for courses (subtract 1 for header)
            final courseIndex = index - 1;
            if (courseIndex >= dashboardController.teacherCourses.length) {
              return SizedBox.shrink();
            }
            final d = dashboardController.teacherCourses[courseIndex];
            return CardWidget(course: d);
          },
        ),
      );
    });
  }
}

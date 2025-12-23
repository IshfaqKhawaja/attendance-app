import 'package:app/app/models/teacher_course.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/widgets/dashboard_scaffold.dart';
import '../../routes/app_routes.dart';
import '../controllers/course_controller.dart';
import '../widgets/attendance_history_dialog.dart';
import 'attendence.dart';

class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

class _CourseState extends State<Course> {
  final TeacherCourseModel course = Get.arguments["course"];

  late CourseController courseController;

  void loadStudentsData() async {
    await courseController.getStudentsList();
    await courseController.getStudentsForAttendence();
  }

  @override
  void initState() {
    super.initState();
    // Use course.courseId as a unique tag to create separate controller instances for each course
    courseController = Get.put(
      CourseController(courseId: course.courseId),
      tag: course.courseId, // Each course gets its own controller instance
    );
    loadStudentsData();
  }

  void _showSaveConfirmation() {
    // Count present students
    final presentCount = courseController.attendenceMarked
        .where((s) => s.marked.any((m) => m))
        .length;
    final totalCount = courseController.attendenceMarked.length;

    if (totalCount == 0) {
      Get.snackbar(
        "No Students",
        "There are no students to mark attendance for.",
        colorText: Colors.orange,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.save, color: Get.theme.primaryColor, size: 28),
            const SizedBox(width: 12),
            Text(
              "Save Attendance?",
              style: GoogleFonts.openSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    Icons.calendar_today,
                    "Date",
                    DateFormat('dd MMM yyyy').format(DateTime.now()),
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    Icons.school,
                    "Course",
                    course.courseName!,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    Icons.check_circle,
                    "Present",
                    "$presentCount students",
                    valueColor: Colors.green,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    Icons.cancel,
                    "Absent",
                    "${totalCount - presentCount} students",
                    valueColor: Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Are you sure you want to save this attendance?",
              style: GoogleFonts.openSans(fontSize: 15),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              courseController.addAttendence();
            },
            icon: const Icon(Icons.check, size: 20),
            label: Text(
              "Yes, Save",
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      headerContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Course name - large and clear
          Text(
            course.courseName!,
            style: GoogleFonts.openSans(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Course code and semester
          Text(
            "Code: ${course.courseId} | ${course.semName}",
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          // Action buttons row - with labels for clarity
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildHeaderButton(
                  icon: Icons.people,
                  label: "Students",
                  onTap: () {
                    Get.toNamed(Routes.STUDENTS, arguments: {"course": course});
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.history,
                  label: "History",
                  onTap: () {
                    AttendanceHistoryDialog.show(
                      context: context,
                      courseId: course.courseId,
                      courseName: "${course.courseName!} (${course.courseId})",
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderButton(
                  icon: Icons.picture_as_pdf,
                  label: "Report",
                  onTap: () {
                    courseController.showDateRangeDialog(
                        context, "${course.courseName!} (${course.courseId})");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bodyContent: Attendence(courseId: course.courseId),
      // Extended FAB with label for better clarity
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSaveConfirmation,
        backgroundColor: Get.theme.primaryColor,
        icon: const Icon(Icons.save, color: Colors.white, size: 24),
        label: Text(
          "Save Attendance",
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/course_by_sem_id_controller.dart';
import '../widgets/add_course.dart';
import '../widgets/edit_course.dart';
import '../widgets/edit_attendance_dialog.dart';
import '../widgets/attendance_history_dialog.dart';
import '../widgets/manage_course_students_dialog.dart';
import 'display_students.dart';
import '../../core/services/user_role_service.dart';
import '../../core/utils/responsive_utils.dart';

class CourseBySemesterId extends StatefulWidget {
  const CourseBySemesterId({super.key});

  @override
  State<CourseBySemesterId> createState() => _CourseBySemesterIdState();
}

class _CourseBySemesterIdState extends State<CourseBySemesterId> {
  final String semesterId = Get.arguments['semesterId'] ?? '';
  final String semesterName = Get.arguments['semesterName'] ?? 'Courses';

  final CourseBySemesterIdController courseController = Get.put(
    CourseBySemesterIdController(),
  );

  // Max width for list items on web
  static const double maxItemWidth = 600;

  @override
  void initState() {
    super.initState();
    courseController.getCoursesBySemesterId(semesterId);
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
        title: Text(
          semesterName,
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          // Attendance Report Button
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Semester Report',
            onPressed: () {
              _showGenerateReportDialog(context);
            },
          ),

          // Show Student List Button (available for all)
          IconButton(
            icon: Icon(Icons.list),
            tooltip: 'View Student List',
            onPressed: () {
              _showStudentListDialog(context);
            },
          ),
          // Add Student Input Button (only for CRUD users)
          if (Get.find<UserRoleService>().canPerformCrud)
            IconButton(
              icon: Icon(Icons.upload_file),
              tooltip: 'Upload Students CSV',
              onPressed: () {
                courseController.selectAndUploadCSVFile(semesterId);
              },
            ),
          // Add button to create new course (only for CRUD users)
          if (Get.find<UserRoleService>().canPerformCrud)
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Course',
              onPressed: () {
                Get.dialog(
                  barrierDismissible: true,
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AddCourse(
                      semesterId: semesterId,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Obx(() {
          if (courseController.coursesBySemesterId.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_book_outlined,
                        size: 40,
                        color: Get.theme.primaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No courses found",
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Tap '+' to add a course",
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
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
                childAspectRatio: 2.0,
              ),
              itemCount: courseController.coursesBySemesterId.length,
              itemBuilder: (context, index) {
                final course = courseController.coursesBySemesterId[index];
                return _buildCourseCard(context, course);
              },
            );
          }

          // Use list on mobile or single column
          return ListView.builder(
            itemCount: courseController.coursesBySemesterId.length,
            itemBuilder: (context, index) {
              final course = courseController.coursesBySemesterId[index];
              // Constrain width on web even for list view
              if (kIsWeb) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxItemWidth),
                    child: _buildCourseCard(context, course),
                  ),
                );
              }
              return _buildCourseCard(context, course);
            },
          );
        }),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, dynamic course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar with gradient
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  Get.theme.primaryColor,
                  Get.theme.primaryColor.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header
                Row(
                  children: [
                    // Course Icon with gradient background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Get.theme.primaryColor.withValues(alpha: 0.15),
                            Get.theme.primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Get.theme.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Course Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.courseName,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course.courseId,
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Teacher Info with icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Icon(Icons.person_outline, size: 14, color: Colors.blue.shade700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          course.assignedTeacherId ?? 'Not Assigned',
                          style: GoogleFonts.openSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade100,
                ),
                const SizedBox(height: 12),
                // Action Buttons - Icon only with tooltips
                Row(
                  children: [
                    // Manage Students Button (only for CRUD users)
                    if (Get.find<UserRoleService>().canPerformCrud)
                      _buildActionButton(
                        icon: Icons.people_outline,
                        label: 'Manage Students',
                        color: Colors.purple,
                        onTap: () {
                          ManageCourseStudentsDialog.show(
                            context: context,
                            courseId: course.courseId,
                            courseName: "${course.courseName} (${course.courseId})",
                            semesterId: semesterId,
                          );
                        },
                      ),
                    if (Get.find<UserRoleService>().canPerformCrud)
                      const SizedBox(width: 8),
                    // View Attendance History Button (available for all - read only)
                    _buildActionButton(
                      icon: Icons.history,
                      label: 'Attendance History',
                      color: Colors.blue,
                      onTap: () {
                        AttendanceHistoryDialog.show(
                          context: context,
                          courseId: course.courseId,
                          courseName: "${course.courseName} (${course.courseId})",
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Edit Attendance Button (only for HOD)
                    if (Get.find<UserRoleService>().isHod)
                      _buildActionButton(
                        icon: Icons.edit_calendar,
                        label: 'Edit Attendance',
                        color: Colors.teal,
                        onTap: () {
                          Get.dialog(
                            EditAttendanceDialog(
                              courseId: course.courseId,
                              courseName: "${course.courseName} (${course.courseId})",
                            ),
                          );
                        },
                      ),
                    if (Get.find<UserRoleService>().isHod)
                      const SizedBox(width: 8),
                    // Generate Report Button (available for all users)
                    _buildActionButton(
                      icon: Icons.summarize,
                      label: 'Generate Report',
                      color: Colors.green,
                      onTap: () {
                        courseController.showReportDatePicker(context, course.courseId);
                      },
                    ),
                    const Spacer(),
                    // Edit Button (only for CRUD users)
                    if (Get.find<UserRoleService>().canPerformCrud)
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit Course',
                        color: Get.theme.primaryColor,
                        onTap: () {
                          Get.dialog(
                            barrierDismissible: true,
                            Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: EditCourse(
                                semesterId: semesterId,
                                course: course,
                              ),
                            ),
                          );
                        },
                      ),
                    if (Get.find<UserRoleService>().canPerformCrud)
                      const SizedBox(width: 8),
                    // Delete Button (only for CRUD users)
                    if (Get.find<UserRoleService>().canPerformCrud)
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete Course',
                        color: Colors.red,
                        onTap: () {
                          _showDeleteConfirmation(context, course);
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(icon, size: 18, color: color),
            ),
          ),
        ),
      ),
    );
  }

  void _showGenerateReportDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? 400 : Get.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.picture_as_pdf,
                  size: 28,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Generate Attendance Report',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                "Do you want to generate attendance report for the semester '$semesterName'?",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        courseController.attendanceForSem(semesterId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Generate',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentListDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.8,
            maxWidth: kIsWeb ? 500 : Get.width * 0.95,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.people, color: Get.theme.primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Student List",
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: DisplayStudents(semId: semesterId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic course) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? 400 : Get.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 28,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Delete Course',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                "Are you sure you want to delete '${course.courseName}'? This action cannot be undone.",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        courseController.deleteCourseById(course.courseId, semesterId);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

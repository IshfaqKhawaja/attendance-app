import 'package:app/app/semester/controllers/semester_controller.dart';
import 'package:app/app/semester/views/add_semester.dart';
import 'package:app/app/semester/widgets/delete_semester_button.dart';
import 'package:app/app/semester/widgets/edit_semester_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../routes/app_routes.dart';
import '../../core/services/user_role_service.dart';
import '../../core/utils/responsive_utils.dart';

class SemesterDashboard extends StatelessWidget {
  SemesterDashboard({super.key});
  final SemesterController semesterController = Get.put(
    SemesterController(
      progId: Get.arguments['prog_id'] ?? '',
    ),
  );

  // Max width for list items on web
  static const double maxItemWidth = 600;

  @override
  Widget build(BuildContext context) {
    var progId = '';
    var progName = 'Semester Dashboard';
    if (Get.arguments != null) {
      progId = Get.arguments['prog_id'] ?? '';
      progName = Get.arguments['prog_name'] ?? 'Semester Dashboard';
    }
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
          progName,
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          // Only show Add button for users with CRUD permissions
          if (Get.find<UserRoleService>().canPerformCrud)
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Add Semester',
              onPressed: () async {
                var added = await showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AddSemester(
                        progId: progId,
                      ),
                    );
                  },
                );
                if (added != null && added is bool && added) {
                  semesterController.getSemestersByProgramId(semesterController.progId);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() {
                if (semesterController.semesters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.calendar_month_outlined,
                              size: 40,
                              color: Colors.orange.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No semesters found",
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tap '+' to add a semester",
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
                      childAspectRatio: 2.5,
                    ),
                    itemCount: semesterController.semesters.length,
                    itemBuilder: (context, index) {
                      final semester = semesterController.semesters[index];
                      return _buildSemesterCard(context, semester);
                    },
                  );
                }

                // Use list on mobile or single column
                return ListView.builder(
                  itemCount: semesterController.semesters.length,
                  itemBuilder: (context, index) {
                    final semester = semesterController.semesters[index];
                    // Constrain width on web even for list view
                    if (kIsWeb) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: maxItemWidth),
                          child: _buildSemesterCard(context, semester),
                        ),
                      );
                    }
                    return _buildSemesterCard(context, semester);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterCard(BuildContext context, dynamic semester) {
    // Calculate if semester is active, upcoming, or past
    final now = DateTime.now();
    final isActive = now.isAfter(semester.startDate) && now.isBefore(semester.endDate);
    final isUpcoming = now.isBefore(semester.startDate);
    final statusColor = isActive ? Colors.green : (isUpcoming ? Colors.blue : Colors.grey);
    final statusText = isActive ? 'Active' : (isUpcoming ? 'Upcoming' : 'Completed');

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
                  Colors.orange,
                  Colors.orange.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              onTap: () {
                Get.toNamed(Routes.COURSEBYSEM, arguments: {
                  'semesterId': semester.semId,
                  'semesterName': semester.semName
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Semester Icon with gradient background
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange.withValues(alpha: 0.15),
                                Colors.orange.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.orange.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Semester Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                semester.semName,
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: statusColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      statusText,
                                      style: GoogleFonts.openSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow indicator
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Divider
                    Container(
                      height: 1,
                      color: Colors.grey.shade100,
                    ),
                    const SizedBox(height: 8),
                    // Date range and actions row
                    Row(
                      children: [
                        // Date range info
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.date_range, size: 14, color: Colors.grey.shade500),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "${DateFormat('MMM dd').format(semester.startDate)} - ${DateFormat('MMM dd, yyyy').format(semester.endDate)}",
                                    style: GoogleFonts.openSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Actions
                        if (!Get.find<UserRoleService>().isViewOnly) ...[
                          const SizedBox(width: 12),
                          // Edit Button
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            color: Get.theme.primaryColor,
                            onTap: () async {
                              var updated = await showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: EditSemesterButton(
                                      semId: semester.semId,
                                      semName: semester.semName,
                                      progId: semester.progId,
                                      startDate: semester.startDate,
                                      endDate: semester.endDate,
                                    ),
                                  );
                                },
                              );
                              if (updated != null && updated is bool && updated) {
                                semesterController.getSemestersByProgramId(semesterController.progId);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          // Delete Button
                          DeleteSemesterButton(semId: semester.semId),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

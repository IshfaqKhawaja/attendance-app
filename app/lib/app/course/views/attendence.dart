import 'package:app/app/course/controllers/course_controller.dart';
import 'package:app/app/course/widgets/attendence_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../widgets/drop_down_widget.dart';

class Attendence extends StatefulWidget {
  final String courseId;

  const Attendence({super.key, required this.courseId});

  @override
  State<Attendence> createState() => _AttendenceState();
}

class _AttendenceState extends State<Attendence> {
  late final CourseController courseController;
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    // Find controller using the course-specific tag
    courseController = Get.find<CourseController>(tag: widget.courseId);
  }
  @override
  void dispose() {
    super.dispose();
    courseController.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsible instruction card - can be dismissed
          if (_showInstructions)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tap checkboxes to mark present, then tap 'Save Attendance'",
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showInstructions = false),
                    child: Icon(Icons.close, size: 18, color: Colors.green.shade600),
                  ),
                ],
              ),
            ),

          // Date and Counted As row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Get.theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
                      style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Classes: ",
                      style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    DropDownWidget(courseId: widget.courseId),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Select All / Deselect All button
          Obx(() {
            final allPresent = courseController.areAllPresent();
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (allPresent) {
                    courseController.deselectAll();
                  } else {
                    courseController.selectAllPresent();
                  }
                },
                icon: Icon(
                  allPresent ? Icons.deselect : Icons.select_all,
                  size: 22,
                ),
                label: Text(
                  allPresent ? "Deselect All" : "Select All Present",
                  style: GoogleFonts.openSans(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: allPresent
                      ? Colors.grey.shade600
                      : Get.theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          // Student list header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Student List",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                  "${courseController.attendenceMarked.where((s) => s.marked.any((m) => m)).length} / ${courseController.attendenceMarked.length} Present",
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                )),
              ],
            ),
          ),

          // Main content area - expands to fill available space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: AttendenceWidget(courseId: widget.courseId),
                        ),
                      ),
                      // Extra padding at bottom so last rows aren't hidden behind FAB
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

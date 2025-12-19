import 'package:app/app/course/controllers/course_controller.dart';
import 'package:app/app/course/widgets/attendence_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/drop_down_widget.dart';
import '../../constants/text_styles.dart' show textStyle;

class Attendence extends StatefulWidget {
  final String courseId;
  
  const Attendence({super.key, required this.courseId});

  @override
  State<Attendence> createState() => _AttendenceState();
}

class _AttendenceState extends State<Attendence> {
  late final CourseController courseController;
  
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row - uses intrinsic height
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  "Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}",
                  style: textStyle.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        "Counted As : ",
                        style: textStyle.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropDownWidget(courseId: widget.courseId),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Select All / Deselect All button
          Obx(() {
            final allPresent = courseController.areAllPresent();
            return Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (allPresent) {
                      courseController.deselectAll();
                    } else {
                      courseController.selectAllPresent();
                    }
                  },
                  icon: Icon(
                    allPresent ? Icons.deselect : Icons.select_all,
                    size: 18,
                  ),
                  label: Text(
                    allPresent ? "Deselect All" : "Select All Present",
                    style: textStyle.copyWith(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allPresent
                        ? Colors.grey
                        : Get.theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "(Mark absent students only)",
                  style: textStyle.copyWith(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            );
          }),
          Divider(thickness: 2, color: Get.theme.primaryColor),
          // Main content area - expands to fill available space
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 80),
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

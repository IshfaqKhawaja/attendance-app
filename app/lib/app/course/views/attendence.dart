import 'package:app/app/course/controllers/course_controller.dart';
import 'package:app/app/course/widgets/attendence_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widgets/drop_down_widget.dart';
import '../../constants/text_styles.dart';

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
          Divider(thickness: 2, color: Get.theme.primaryColor),
          // Main content area - expands to fill available space
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black12.withValues(alpha: 0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AttendenceWidget(courseId: widget.courseId),
                ),
              ),
            ),
          ),
          // Button area - fixed minimum height with padding
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            color: Colors.black12.withValues(alpha: 0.1),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  courseController.addAttendence();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Add Attendance",
                      style: textStyle.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.save_as, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

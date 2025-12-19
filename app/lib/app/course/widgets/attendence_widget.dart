import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/text_styles.dart';
import '../controllers/course_controller.dart';

class AttendenceWidget extends StatefulWidget {
  final String courseId;

  const AttendenceWidget({super.key, required this.courseId});

  @override
  State<AttendenceWidget> createState() => _AttendenceWidgetState();
}

class _AttendenceWidgetState extends State<AttendenceWidget> {
  late final CourseController courseController;

  @override
  void initState() {
    super.initState();
    // Find controller using the course-specific tag
    courseController = Get.find<CourseController>(tag: widget.courseId);
  }

  /// Get the count of present (true) values in the marked list
  int _getPresentCount(List<bool> marked) {
    return marked.where((m) => m).length;
  }

  /// Set the marked list based on the count selected
  /// If count is 2 and total slots is 3, mark first 2 as true, rest as false
  void _setPresentCount(int rowIndex, int count) {
    final markedList = courseController.attendenceMarked[rowIndex].marked;
    final totalSlots = courseController.countedAs.value;

    // Ensure the marked list has the right size
    while (markedList.length < totalSlots) {
      markedList.add(false);
    }

    // Set first 'count' items to true, rest to false
    for (int i = 0; i < totalSlots; i++) {
      markedList[i] = i < count;
    }

    courseController.attendenceMarked.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = textStyle.copyWith(fontSize: 14, fontWeight: FontWeight.bold);
    final rowStyle = textStyle.copyWith(fontSize: 12);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        final countedAs = courseController.countedAs.value;

        return DataTable(
          columnSpacing: 30,
          columns: [
            DataColumn(label: Text("ID", style: headerStyle)),
            DataColumn(label: Text("Name", style: headerStyle)),
            DataColumn(
              label: Text(
                countedAs > 1 ? "Present (0-$countedAs)" : "Present",
                style: headerStyle,
              ),
            ),
          ],
          rows: List.generate(courseController.attendenceMarked.length, (rowIndex) {
            final attendance = courseController.attendenceMarked[rowIndex];
            final presentCount = _getPresentCount(attendance.marked);

            return DataRow(
              cells: [
                DataCell(
                  Text(attendance.studentId, style: rowStyle),
                ),
                DataCell(
                  Text(attendance.studentName, style: rowStyle),
                ),
                DataCell(
                  countedAs > 1
                      ? _buildDropdown(rowIndex, presentCount, countedAs)
                      : _buildCheckbox(rowIndex, presentCount > 0),
                ),
              ],
            );
          }),
        );
      }),
    );
  }

  /// Build dropdown for multiple slots (counted as > 1)
  Widget _buildDropdown(int rowIndex, int currentCount, int maxCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: currentCount,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: List.generate(maxCount + 1, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(
                index == 0 ? '0 (Absent)' : '$index',
                style: textStyle.copyWith(
                  fontSize: 14,
                  color: index == 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              _setPresentCount(rowIndex, value);
            }
          },
        ),
      ),
    );
  }

  /// Build checkbox for single slot (counted as = 1)
  Widget _buildCheckbox(int rowIndex, bool isPresent) {
    return Checkbox(
      value: isPresent,
      activeColor: Get.theme.colorScheme.primary,
      onChanged: (bool? val) {
        _setPresentCount(rowIndex, val == true ? 1 : 0);
      },
    );
  }
}

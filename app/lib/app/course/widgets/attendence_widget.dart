import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/text_styles.dart';
import '../controllers/course_controller.dart';

class AttendenceWidget extends StatefulWidget {
  const AttendenceWidget({super.key});

  @override
  State<AttendenceWidget> createState() => _AttendenceWidgetState();
}

class _AttendenceWidgetState extends State<AttendenceWidget> {
  final CourseController courseController = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = textStyle.copyWith(fontSize: 14);
    final rowStyle = textStyle.copyWith(fontSize: 12);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return DataTable(
          columnSpacing: courseController.countedAs.value == 0
              ? 45.0
              : 45 / courseController.countedAs.value,
          columns: [
            DataColumn(label: Text("ID", style: headerStyle)),
            DataColumn(label: Text("Name", style: headerStyle)),
            ...List.generate(
              courseController.countedAs.value,
              (index) => DataColumn(
                label: Text("Slot ${index + 1}", style: headerStyle),
              ),
            ),
          ],
          rows: List.generate(courseController.attendenceMarked.length, (
            rowIndex,
          ) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    courseController.attendenceMarked[rowIndex].studentId,
                    style: rowStyle,
                  ),
                ),
                DataCell(
                  Text(
                    courseController.attendenceMarked[rowIndex].studentName,
                    style: rowStyle,
                  ),
                ),
                ...List.generate(
                  courseController.countedAs.value,
                  (colIndex) {
                    final markedList =
                        courseController.attendenceMarked[rowIndex].marked;
                    final bool currentValue = (colIndex < markedList.length)
                        ? markedList[colIndex]
                        : false;
                    return DataCell(
                      Checkbox(
                        value: currentValue,
                        onChanged: (bool? val) {
                          final newVal = val ?? false;
                          // Ensure the marked list is large enough before writing.
                          if (colIndex < markedList.length) {
                            markedList[colIndex] = newVal;
                          } else {
                            markedList.addAll(List<bool>.filled(
                                colIndex - markedList.length + 1, false));
                            markedList[colIndex] = newVal;
                          }
                          courseController.attendenceMarked.refresh();
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        );
      }),
    );
  }
}

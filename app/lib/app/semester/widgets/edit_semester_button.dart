import 'package:app/app/semester/controllers/edit_semester_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/typography.dart';

class EditSemesterButton extends StatefulWidget {
  final String semId;
  final String semName;
  final String progId;
  final DateTime startDate;
  final DateTime endDate;
  const EditSemesterButton({super.key, required this.semId, required this.semName, required this.progId, required this.startDate, required this.endDate});

  @override
  State<EditSemesterButton> createState() => _EditSemesterButtonState();
}

class _EditSemesterButtonState extends State<EditSemesterButton> {
  late EditSemesterController editSemesterController =  Get.put(EditSemesterController());
  @override
  void initState() {
    super.initState();
    editSemesterController.initializeFields(
      semId: widget.semId,
      semName: widget.semName,
      start: widget.startDate,
      end: widget.endDate,
      progId: widget.progId
    );
  }
  @override
  Widget build(BuildContext context) {
    final height = Get.size.height * 0.4;
    final sizedBox = SizedBox(height: 20);
    return Obx(() {
      return Container(
              padding: const EdgeInsets.all(10.0),
              height: height,
              child: ListView(
                  children: [
                    Text(
                      'Edit Semester',
                      style: textStyle.copyWith(fontSize: 24),
                    ),
                    sizedBox,
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Semester Name'),
                      controller: editSemesterController.semesterNameController.value,
                    ),
                    sizedBox,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Start: ${DateFormat('dd/MM/yy').format(editSemesterController.startDate.value.value ?? widget.startDate)}',
                            style: textStyle.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'End: ${DateFormat('dd/MM/yy').format(editSemesterController.endDate.value.value ?? widget.endDate)}',
                            style: textStyle.copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    sizedBox,
                    // Select Start/End Date Button
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await editSemesterController.selectStartDate(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("Edit Start", textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await editSemesterController.selectEndDate(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text("Edit End", textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ],
                    ), 
                    sizedBox,
                    ElevatedButton(
                      onPressed: () async {
                        final edited = await editSemesterController.editSemester();
                        Navigator.of(context).pop(edited);
                      },
                      child: Text("Edit", style: textStyle.copyWith(fontSize: 16),)
                    ),
                  ]
                ),
              );
            });
    }

}
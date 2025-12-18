import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


import '../../core/constants/typography.dart';
import '../../semester/controllers/add_semester_controller.dart';

class AddSemester extends StatefulWidget {

  final String progId;
  AddSemester({super.key, required this.progId});

  @override
  State<AddSemester> createState() => _AddSemesterState();
}

class _AddSemesterState extends State<AddSemester> {
  final AddSemesterController addSemesterController = Get.put(AddSemesterController());

  // Max width for dialog on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
    addSemesterController.emptyFields();
  }

  @override
  Widget build(BuildContext context) {
    final sizedBox = SizedBox(height: 20);

    return Container(
      padding: const EdgeInsets.all(10.0),
      width: kIsWeb ? null : Get.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
        maxHeight: Get.size.height * 0.45,
      ),
      child: Obx((){
        final startDate = addSemesterController.startDate.value;
        final endDate = addSemesterController.endDate.value;
        return ListView(
          children: [
             Text(
              'Add Semester',
              style: textStyle.copyWith(fontSize: 24),
            ),
            sizedBox,
            TextFormField(
              decoration: const InputDecoration(labelText: 'Semester Name'),
              controller: addSemesterController.semesterNameController.value,
            ),
            sizedBox,
            Row(
              children: [
                if (startDate != null)
                  Expanded(
                    child: Text(
                      'Start: ${DateFormat('dd/MM/yy').format(startDate)}',
                      style: textStyle.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (startDate != null && endDate != null)
                  SizedBox(width: 8),
                if (endDate != null)
                  Expanded(
                    child: Text(
                      'End: ${DateFormat('dd/MM/yy').format(endDate)}',
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
                      await addSemesterController.selectStartDate(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Select Start", textAlign: TextAlign.center),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await addSemesterController.selectEndDate(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Select End", textAlign: TextAlign.center),
                    ),
                  ),
                ),
              ],
            ), 
            sizedBox,
            ElevatedButton(
              onPressed: () async {
                final added = await addSemesterController.addSemester(widget.progId);
                Navigator.of(context).pop(added);
              },
              child: Text("Add Semester", style: textStyle.copyWith(fontSize: 16),)
            ),
          ]
        );
      }
      ),
    );
  }
}
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

  @override
  void initState() {
    super.initState();
    addSemesterController.emptyFields();
  }

  @override
  Widget build(BuildContext context) {
    final sizedBox = SizedBox(height: 20);
    final height = Get.size.height * 0.35;
    
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: height,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (startDate != null)
                  Text('Start Date: ${DateFormat('dd/MM/yyyy').format(startDate)}', style: textStyle.copyWith(fontSize: 12),),
                if (endDate != null)
                  Text('End Date: ${DateFormat('dd/MM/yyyy').format(endDate)}', style: textStyle.copyWith(fontSize: 12),),
              ],
            ),
            sizedBox,
            // Select Start/End Date Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () async {
                 await addSemesterController.selectStartDate(context);
                }, child: Text("Select Start Date"),),
        
                ElevatedButton(onPressed: () async {
                   await addSemesterController.selectEndDate(context);
                }, child: Text("Select End Date"),),
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
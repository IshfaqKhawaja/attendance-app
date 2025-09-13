

import 'package:app/app/core/constants/typography.dart';
import 'package:app/app/dashboard/hod/controllers/add_teacher_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTeacherDialog extends StatefulWidget {
  AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final AddTeacherController addTeacherController = Get.put(
    AddTeacherController(),
  );
  @override
  void initState() {
    super.initState();
    addTeacherController.clearFields();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Add Teacher"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "ID"),
              controller: addTeacherController.emailController.value,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              controller: addTeacherController.nameController.value,
            ),
            Obx(() {
              return DropdownButtonFormField<String>(
                value: addTeacherController.teacherType.isNotEmpty
                    ? addTeacherController.teacherType.first
                    : null,
                items: addTeacherController.teacherType
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    addTeacherController.selectedTeacherType.value = value;
                  }
                },
                decoration: InputDecoration(labelText: "Type"),
              );
            }),
           
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final added = await addTeacherController.addTeacher();
              Navigator.of(context).pop(added);
            },
            child: Text("Add", style: textStyle.copyWith(fontSize: 16,),),
          ),
           TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Cancel", style: textStyle.copyWith(fontSize: 16,),),
          ),
        ],
      );
  }
}
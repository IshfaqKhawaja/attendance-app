import 'package:app/app/core/constants/typography.dart';
import 'package:app/app/dashboard/hod/controllers/add_teacher_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  // Max width for dialog on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
    addTeacherController.clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
          minWidth: kIsWeb ? maxDialogWidth : 280,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Teacher", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "e.g., teacher@university.edu",
                ),
                controller: addTeacherController.emailController.value,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text("Cancel", style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () async {
            final added = await addTeacherController.addTeacher();
            if (context.mounted) {
              Navigator.of(context).pop(added);
            }
          },
          child: Text("Add", style: textStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

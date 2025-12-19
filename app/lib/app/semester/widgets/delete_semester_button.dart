import 'package:app/app/semester/controllers/semester_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteSemesterButton extends StatelessWidget {
  final String semId;
  DeleteSemesterButton({super.key, required this.semId});
  final SemesterController semesterController = Get.find<SemesterController>();
  @override
  Widget build(BuildContext context) {
    return  IconButton(
          icon: Icon(Icons.delete, color: Colors.red,),
          tooltip: 'Delete Semester',
          onPressed: () async {
            final confirmed = await Get.dialog(
              AlertDialog(
                title: Text("Confirm Deletion"),
                content: Text("Are you sure you want to delete this semester?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text("Delete", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              semesterController.deleteSemester(semId);
            }
          },
        );
  }
}
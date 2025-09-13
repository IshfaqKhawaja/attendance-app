



import 'package:app/app/dashboard/hod/controllers/edit_teacher_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/teacher_model.dart';
import '../controllers/manage_teachers_controller.dart';

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  TeacherCard({super.key, required this.teacher});
  final ManageTeachersController controller = Get.find<ManageTeachersController>();
  final EditTeacherController editTeacherController = Get.put(EditTeacherController());

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        margin: EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Get.theme.primaryColorLight,
            child: Text(
              teacher.teacher_name.isNotEmpty ? teacher.teacher_name[0].toUpperCase() : '',
              style: GoogleFonts.openSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            teacher.teacher_name,
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher.teacher_id,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                  teacher.type,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          trailing: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit Button
                IconButton(
                  onPressed: () async {
                    editTeacherController.updateData(
                      id: teacher.teacher_id,
                      name: teacher.teacher_name,
                      type: teacher.type
                    );
                    final edited = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Edit Teacher"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                                  controller: TextEditingController(text: teacher.teacher_id),
                                  decoration: InputDecoration(labelText: "Id"),
                                  onChanged: (value) {
                                    editTeacherController.teacherId.value = value;
                                  },
                                ),
                            TextField(
                                  controller: TextEditingController(text: teacher.teacher_name),
                                  decoration: InputDecoration(labelText: "Teacher Name"),
                                  onChanged: (value) {
                                    editTeacherController.teacherName.value = value;
                                  },
                                ),
                            DropdownButtonFormField<String>(
                                  value: teacher.type,
                                  items: editTeacherController.teacherType
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      editTeacherController.selectedTeacherType.value = value;
                                    }
                                  }, 
                                  decoration: InputDecoration(labelText: "Teacher Type"),
                                ),


                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async  {
                                  // Save the changes
                                  var updated = await editTeacherController.updateTeacher(
                                    teacher.teacher_id,
                                  );
                                  Navigator.of(context).pop(updated);
                                },
                                child: Text("Save"),
                              ),
                            ],
                          ),
                        );


                        if (edited == true) {
                          controller.loadTeachers();
                        }
                      },
                      icon: Icon(Icons.edit, color: Get.theme.primaryColor),
    
                    ),


                // Delete Button
                IconButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Confirm Deletion"),
                        content: Text("Are you sure you want to delete ${teacher.teacher_name}?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text("Delete", style: TextStyle(color: Colors.redAccent),),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await controller.deleteTeacher(teacher.teacher_id);
                      controller.loadTeachers();
                    }
                  },
                  icon: Icon(Icons.delete, color: Colors.redAccent),
                ),
              ],
            ),
          ),
        ),
        );
  }
}
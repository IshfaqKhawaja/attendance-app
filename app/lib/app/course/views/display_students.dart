import 'package:app/app/course/controllers/course_by_sem_id_controller.dart';
import 'package:app/app/course/widgets/add_student.dart';
import 'package:app/app/course/widgets/edit_student.dart';
import 'package:app/app/core/services/user_role_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Max width for dialogs on web
const double _maxDialogWidth = 400;

class DisplayStudents extends StatefulWidget {
  final String semId;
  const DisplayStudents({super.key, required this.semId});

  @override
  State<DisplayStudents> createState() => _DisplayStudentsState();
}

class _DisplayStudentsState extends State<DisplayStudents> {
  final CourseBySemesterIdController courseController = Get.find<CourseBySemesterIdController>();

  @override
  void initState() {
    super.initState();
    courseController.fetchStudentsInThisSem(widget.semId);
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = Get.find<UserRoleService>().canPerformCrud;

    return Column(
      children: [
        // Add Student Button at the top (only for users with CRUD permissions)
        if (canEdit)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.dialog(
                  Dialog(
                    child: AddStudent(semesterId: widget.semId),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add Student'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 45),
              ),
            ),
          ),
        // Student List
        Expanded(
          child: Obx(() {
            if (courseController.studentsInThisSem.isEmpty) {
              return Center(
                child: Text("No students enrolled in this semester."),
              );
            }
            return ListView.builder(
              itemCount: courseController.studentsInThisSem.length,
              itemBuilder: (context, index) {
                final student = courseController.studentsInThisSem[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('S${index + 1}'),
                  ),
                  title: Text(student.studentName),
                  subtitle: Text(student.studentId),
                  trailing: canEdit
                      ? IntrinsicWidth(
                          child: Row(
                            children: [
                              // Edit button
                              IconButton(
                                onPressed: () {
                                  Get.dialog(
                                    Dialog(
                                      child: EditStudent(
                                        semesterId: widget.semId,
                                        student: student,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit, size: 20, color: Get.theme.colorScheme.primary),
                              ),
                              // Delete button
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Remove Student", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        contentPadding: EdgeInsets.zero,
                                        content: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: kIsWeb ? _maxDialogWidth : double.infinity,
                                            minWidth: kIsWeb ? _maxDialogWidth : 280,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Text("Are you sure you want to remove '${student.studentName}' from this semester?", style: TextStyle(fontSize: 14)),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Get.back();
                                              await courseController.deleteStudentFromSem(student.studentId, widget.semId);
                                            },
                                            child: Text("Remove", style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: Icon(Icons.delete, color: Colors.red),
                              )
                            ],
                          ),
                        )
                      : null,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
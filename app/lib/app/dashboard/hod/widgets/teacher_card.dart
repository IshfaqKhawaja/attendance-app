import 'package:app/app/dashboard/hod/controllers/edit_teacher_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/teacher_model.dart';
import '../controllers/manage_teachers_controller.dart';
import '../../../core/services/user_role_service.dart';

// Max width for dialogs on web
const double _maxDialogWidth = 450;

class TeacherCard extends StatelessWidget {
  final Teacher teacher;
  TeacherCard({super.key, required this.teacher});

  // Use getter to find controller at runtime, ensuring it exists when accessed
  ManageTeachersController get controller => Get.find<ManageTeachersController>();
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
          trailing: Get.find<UserRoleService>().isViewOnly
              ? null // No actions for view-only users (super admin)
              : IntrinsicWidth(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        tooltip: 'Edit Teacher',
                        onPressed: () async {
                          editTeacherController.updateData(
                            id: teacher.teacher_id,
                            name: teacher.teacher_name,
                            type: teacher.type
                          );
                          final edited = await _showEditTeacherDialog(context);
                          if (edited == true) {
                            controller.loadTeachers();
                          }
                        },
                        icon: Icon(Icons.edit, color: Get.theme.primaryColor),
                      ),

                      // Delete Button
                      IconButton(
                        tooltip: 'Delete Teacher',
                        onPressed: () async {
                          final confirmed = await _showDeleteConfirmation(context);
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

  Future<bool?> _showEditTeacherDialog(BuildContext context) {
    final nameController = TextEditingController(text: teacher.teacher_name);
    final emailController = TextEditingController(text: teacher.teacher_id);

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? _maxDialogWidth : Get.width * 0.9,
            maxHeight: Get.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.edit, color: Get.theme.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Edit Teacher',
                        style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Dr. John Smith',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: GoogleFonts.openSans(fontSize: 16),
                  onChanged: (value) {
                    editTeacherController.teacherName.value = value;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email *',
                    hintText: 'e.g., teacher@university.edu',
                    prefixIcon: Icon(Icons.email),
                    helperText: 'This is the login email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.openSans(fontSize: 16),
                  onChanged: (value) {
                    editTeacherController.teacherId.value = value;
                  },
                ),
                const SizedBox(height: 16),

                // Teacher Type Dropdown
                Text(
                  "Teacher Type *",
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text(
                          "Select teacher type",
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                        isExpanded: true,
                        value: editTeacherController.selectedTeacherType.value.isNotEmpty
                            ? editTeacherController.selectedTeacherType.value
                            : teacher.type,
                        items: editTeacherController.teacherType
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: GoogleFonts.openSans(fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            editTeacherController.selectedTeacherType.value = value;
                          }
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          var updated = await editTeacherController.updateTeacher(
                            teacher.teacher_id,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop(updated);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.save, color: Colors.white, size: 18),
                        label: Text(
                          'Save',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? 400 : Get.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 28,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Delete Teacher',
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                "Are you sure you want to delete '${teacher.teacher_name}'?",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

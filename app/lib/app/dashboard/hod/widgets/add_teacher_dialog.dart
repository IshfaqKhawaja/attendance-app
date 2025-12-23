import 'package:app/app/dashboard/hod/controllers/add_teacher_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTeacherDialog extends StatefulWidget {
  const AddTeacherDialog({super.key});

  @override
  State<AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<AddTeacherDialog> {
  final AddTeacherController addTeacherController = Get.put(
    AddTeacherController(),
  );

  // Max width for dialog on web
  static const double maxDialogWidth = 450;

  @override
  void initState() {
    super.initState();
    addTeacherController.clearFields();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        width: kIsWeb ? null : Get.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
          maxHeight: Get.height * 0.6,
        ),
        child: Form(
          child: ListView(
            shrinkWrap: true,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.person_add, color: Get.theme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add New Teacher',
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
                decoration: InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., Dr. John Smith',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: addTeacherController.nameController.value,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'e.g., teacher@university.edu',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: addTeacherController.emailController.value,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.openSans(fontSize: 16),
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
                      value: addTeacherController.selectedTeacherType.value.isNotEmpty
                          ? addTeacherController.selectedTeacherType.value
                          : null,
                      items: addTeacherController.teacherType
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
                          addTeacherController.selectedTeacherType.value = value;
                        }
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Add Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: Get.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final added = await addTeacherController.addTeacher();
                  if (context.mounted) {
                    Navigator.of(context).pop(added);
                  }
                },
                label: Text(
                  'Add Teacher',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

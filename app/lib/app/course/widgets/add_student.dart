import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/course_by_sem_id_controller.dart';

class AddStudent extends StatefulWidget {
  final String semesterId;
  const AddStudent({super.key, required this.semesterId});

  @override
  State<AddStudent> createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final CourseBySemesterIdController controller = Get.find<CourseBySemesterIdController>();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  // Max width for dialog on web
  static const double maxDialogWidth = 450;

  @override
  void dispose() {
    studentIdController.dispose();
    studentNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: kIsWeb ? null : Get.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
        maxHeight: Get.height * 0.55,
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
                    'Add New Student',
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Student ID
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Student ID *',
                hintText: 'e.g., STU001, 2024001',
                prefixIcon: Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: studentIdController,
              style: GoogleFonts.openSans(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Student Name
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Student Name *',
                hintText: 'e.g., John Doe',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: studentNameController,
              style: GoogleFonts.openSans(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'e.g., 1234567890',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.openSans(fontSize: 16),
            ),
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
                final navigator = Navigator.of(context);
                try {
                  await controller.addStudent(
                    studentIdController.text,
                    studentNameController.text,
                    phoneNumberController.text,
                    widget.semesterId,
                  );
                } catch (e) {
                  print('Error adding student: $e');
                } finally {
                  try {
                    navigator.pop();
                  } catch (e) {
                    print('Error closing dialog: $e');
                  }
                }
              },
              label: Text(
                'Add Student',
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
    );
  }
}

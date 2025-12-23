import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/student_model.dart';
import '../controllers/course_controller.dart';

class EditStudentInCourse extends StatefulWidget {
  final String semesterId;
  final String courseId;
  final StudentModel student;
  const EditStudentInCourse({super.key, required this.semesterId, required this.courseId, required this.student});

  @override
  State<EditStudentInCourse> createState() => _EditStudentInCourseState();
}

class _EditStudentInCourseState extends State<EditStudentInCourse> {
  late final CourseController controller;
  late final TextEditingController studentIdController;
  late final TextEditingController studentNameController;
  late final TextEditingController phoneNumberController;

  // Max width for dialog on web
  static const double maxDialogWidth = 450;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CourseController>(tag: widget.courseId);
    // Pre-fill with existing student data
    studentIdController = TextEditingController(text: widget.student.studentId);
    studentNameController = TextEditingController(text: widget.student.studentName);
    phoneNumberController = TextEditingController(text: widget.student.phoneNumber);
  }

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
                Icon(Icons.edit, color: Get.theme.primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Student',
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

            // Update Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                backgroundColor: Get.theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  await controller.editStudent(
                    widget.student.studentId,
                    studentNameController.text,
                    phoneNumberController.text,
                    widget.semesterId,
                    newStudentId: studentIdController.text,
                  );
                } catch (e) {
                  debugPrint('Error updating student: $e');
                } finally {
                  try {
                    navigator.pop();
                  } catch (e) {
                    debugPrint('Error closing dialog: $e');
                  }
                }
              },
              label: Text(
                'Update Student',
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

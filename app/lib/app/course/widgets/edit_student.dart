import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/student_model.dart';
import '../controllers/course_by_sem_id_controller.dart';

class EditStudent extends StatefulWidget {
  final String semesterId;
  final StudentInSemModel student;
  const EditStudent({super.key, required this.semesterId, required this.student});

  @override
  State<EditStudent> createState() => _EditStudentState();
}

class _EditStudentState extends State<EditStudent> {
  final CourseBySemesterIdController controller = Get.find<CourseBySemesterIdController>();
  late final TextEditingController studentIdController;
  late final TextEditingController studentNameController;
  late final TextEditingController phoneNumberController;

  // Max width for dialog on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
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
      padding: const EdgeInsets.all(16.0),
      width: kIsWeb ? null : Get.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
        maxHeight: Get.height * 0.45,
      ),
      child: Form(
        child: ListView(
          children: [
            Text(
              'Edit Student',
              style: textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
              ),
              controller: studentIdController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
              controller: studentNameController,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Get.theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                try {
                  await controller.editStudent(
                    widget.student.studentId,
                    studentIdController.text,
                    studentNameController.text,
                    phoneNumberController.text,
                    widget.semesterId,
                  );
                } catch (e) {
                  print('Error updating student: $e');
                } finally {
                  // Close dialog after operation completes
                  try {
                    navigator.pop();
                  } catch (e) {
                    print('Error closing dialog: $e');
                  }
                }
              },
              child: Text(
                'Update Student',
                style: textStyle.copyWith(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

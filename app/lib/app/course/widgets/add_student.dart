import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      height: Get.height * 0.45,
      width: Get.width,
      child: Form(
        child: ListView(
          children: [
            Text(
              'Add Student',
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
                  await controller.addStudent(
                    studentIdController.text,
                    studentNameController.text,
                    phoneNumberController.text,
                    widget.semesterId,
                  );
                } catch (e) {
                  print('Error adding student: $e');
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
                'Add Student',
                style: textStyle.copyWith(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/course_controller.dart';

class AddStudentToCourse extends StatefulWidget {
  final String semesterId;
  final String courseId;
  const AddStudentToCourse({super.key, required this.semesterId, required this.courseId});

  @override
  State<AddStudentToCourse> createState() => _AddStudentToCourseState();
}

class _AddStudentToCourseState extends State<AddStudentToCourse> {
  late final CourseController controller;
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  // Max width for dialog on web
  static const double maxDialogWidth = 400;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CourseController>(tag: widget.courseId);
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
        maxHeight: Get.height * 0.5,
      ),
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
                } finally {
                  try {
                    print("closing dialog");
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

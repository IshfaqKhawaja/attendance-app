import 'package:app/app/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  late final TextEditingController studentNameController;
  late final TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CourseController>(tag: widget.courseId);
    // Pre-fill with existing student data
    studentNameController = TextEditingController(text: widget.student.studentName);
    phoneNumberController = TextEditingController(text: widget.student.phoneNumber);
  }

  @override
  void dispose() {
    studentNameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: Get.height * 0.4,
      width: Get.width,
      child: Form(
        child: ListView(
          children: [
            Text(
              'Edit Student',
              style: textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Student ID: ${widget.student.studentId}',
              style: textStyle.copyWith(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
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
              onPressed: () {
                controller.editStudent(
                  widget.student.studentId,
                  studentNameController.text,
                  phoneNumberController.text,
                  widget.semesterId,
                );
                Get.back();
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

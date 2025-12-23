import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../signin/models/teacher_model.dart';
import '../controllers/course_by_sem_id_controller.dart';

class AddCourse extends StatefulWidget {
  final String semesterId;
  const AddCourse({super.key, required this.semesterId});

  @override
  State<AddCourse> createState() => _AddCourseState();
}

class _AddCourseState extends State<AddCourse> {
  final CourseBySemesterIdController courseController = Get.put(CourseBySemesterIdController());

  // Max width for dialog on web
  static const double maxDialogWidth = 450;

  // Track loading state
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    courseController.clear();
    courseController.fetchTeachersInThisDept();
    // Give time for teachers to load, then update UI
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      width: kIsWeb ? null : Get.width * 0.9,
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? maxDialogWidth : double.infinity,
        maxHeight: Get.height * 0.7,
      ),
      child: _isLoading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  "Loading teachers...",
                  style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey),
                ),
              ],
            )
          : Obx(() {
        // Check if no teachers available after loading
        final noTeachers = courseController.teachersInThisDept.isEmpty;

        if (noTeachers) {
          // Show warning when no teachers exist
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add Teachers First',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.orange.shade600),
                    const SizedBox(height: 12),
                    Text(
                      "No teachers found in this department",
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "You need to add teachers before you can create courses. Each course must be assigned to a teacher.",
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Steps guide
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Follow these steps:",
                      style: GoogleFonts.openSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStepRow("1", "Go to the 'Teachers' tab"),
                    _buildStepRow("2", "Add teachers to your department"),
                    _buildStepRow("3", "Come back here to add courses"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Get.theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Got it',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // Normal add course form
        return Form(
          child: ListView(
            shrinkWrap: true,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.add_circle, color: Get.theme.primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add New Course',
                      style: GoogleFonts.openSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Course Code
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Code *',
                  hintText: 'e.g., CS101, MATH201',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: courseController.courseIdController,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Course Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Course Name *',
                  hintText: 'e.g., Introduction to Programming',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: courseController.nameController,
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Teacher dropdown
              Text(
                "Assign Teacher *",
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TeacherModel>(
                    hint: Text(
                      "Select a teacher",
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                    isExpanded: true,
                    value: courseController.selectedTeacher.value,
                    items: courseController.teachersInThisDept.map((TeacherModel teacher) {
                      return DropdownMenuItem<TeacherModel>(
                        value: teacher,
                        child: Text(
                          teacher.teacherName,
                          style: GoogleFonts.openSans(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (TeacherModel? newValue) {
                      courseController.selectedTeacher.value = newValue;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Add button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: Get.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  final courseId = courseController.courseIdController.text.trim();
                  final courseName = courseController.nameController.text.trim();

                  // Validate before closing
                  if (courseId.isEmpty) {
                    Get.snackbar("Error", "Please enter course code",
                      colorText: Colors.red,
                    );
                    return;
                  }
                  if (courseName.isEmpty) {
                    Get.snackbar("Error", "Please enter course name",
                      colorText: Colors.red,
                    );
                    return;
                  }
                  if (courseController.selectedTeacher.value == null) {
                    Get.snackbar("Error", "Please select a teacher",
                      colorText: Colors.red,
                    );
                    return;
                  }

                  courseController.addCourse(
                    courseId,
                    courseName,
                    widget.semesterId,
                  );
                  Get.back();
                },
                label: Text(
                  'Add Course',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
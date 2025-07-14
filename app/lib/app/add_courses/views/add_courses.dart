import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Local Imports
import '../../constants/text_styles.dart';
import '../controllers/add_courses_controller.dart';
import '../widgets/course_drop_down.dart';
import '../widgets/department_drop_down.dart';
import '../widgets/faculty_drop_down.dart';
import '../widgets/program_drop_down.dart';
import '../widgets/semester_drop_down.dart';

Widget textWidget(String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      value,
      style: textStyle.copyWith(fontSize: 20, fontStyle: FontStyle.normal),
    ),
  );
}

class AddCourses extends StatefulWidget {
  const AddCourses({super.key});

  @override
  State<AddCourses> createState() => _AddCoursesState();
}

class _AddCoursesState extends State<AddCourses> {
  final AddCoursesController addCoursesController = Get.put(
    AddCoursesController(),
    permanent: true,
  );

  @override
  void initState() {
    super.initState();
    addCoursesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final sizedBox = SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          textWidget("Add Your Current Courses"),
          sizedBox,
          textWidget("Name of Faculty"),
          FacultyDropDown(),
          sizedBox,
          textWidget("Name of Department"),
          DepartmentDropDown(),
          sizedBox,
          textWidget("Name of Program"),
          ProgramDropDown(),
          sizedBox,
          textWidget("Semesters"),
          SemesterDropDown(),
          sizedBox,
          textWidget("Courses"),
          CourseDropDown(),
          sizedBox,
          Obx(() {
            debugPrint("${addCoursesController.selectedFaculties.length}");
            return ElevatedButton(
              onPressed: () async {
                addCoursesController.add_courses();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text("Add Courses", style: buttonTextStyle),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Local Imports
import '../../models/course_model.dart';
import '../../constants/text_styles.dart';
import '../controllers/add_courses_controller.dart';

class CourseDropDown extends StatelessWidget {
  CourseDropDown({super.key});
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final AddCoursesController registerController =
      Get.find<AddCoursesController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = registerController.dropDownCourseOptions.toList();
      return DropdownSearch<CourseModel>.multiSelection(
        key: dropDownKey,
        // 1) Tell it how to find your items (even if it’s instant)
        items: (_, _) => list,

        // 2) How to render each item in the text field & list
        itemAsString: (item) => item.courseName,

        // 3) How to compare objects (required for non-primitive T)
        compareFn: (CourseModel a, CourseModel b) => a.courseId == b.courseId,

        // 4) Your current selection, if any
        selectedItems: registerController.selectedCourses,

        // 5) Whenever they pick a new one...
        onChanged: (List<CourseModel> selections) {
          registerController.selectedCourses.assignAll(selections);
        },

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Course :',
            hintText: 'Select Course',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue, width: 1.0),
            ),
          ),
          baseStyle: dropDownTextStyle,
        ),
        popupProps: const PopupPropsMultiSelection.menu(
          fit: FlexFit.loose,
          constraints: BoxConstraints(),
        ),
      );
    });
  }
}

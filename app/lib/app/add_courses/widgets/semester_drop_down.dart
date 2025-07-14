import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Local Imports
import '../../models/semester_model.dart';
import '../../constants/text_styles.dart';
import '../controllers/add_courses_controller.dart';

class SemesterDropDown extends StatelessWidget {
  SemesterDropDown({super.key});
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final AddCoursesController registerController =
      Get.find<AddCoursesController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = registerController.dropDownSemesterOptions.toList();
      return DropdownSearch<SemesterModel>.multiSelection(
        key: dropDownKey,
        // 1) Tell it how to find your items (even if it’s instant)
        items: (_, _) => list,

        // 2) How to render each item in the text field & list
        itemAsString: (item) => item.semName,

        // 3) How to compare objects (required for non-primitive T)
        compareFn: (SemesterModel a, SemesterModel b) => a.semId == b.semId,

        // 4) Your current selection, if any
        selectedItems: registerController.selectedSemesters,

        // 5) Whenever they pick a new one...
        onChanged: (List<SemesterModel> selections) {
          registerController.selectedSemesters.assignAll(selections);
          registerController.changeCourse();
        },

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Semester :',
            hintText: 'Select Semester',
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

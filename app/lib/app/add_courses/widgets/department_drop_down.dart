import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Local Imports
import '../../models/department_model.dart';
import '../../constants/text_styles.dart';
import '../controllers/add_courses_controller.dart';

class DepartmentDropDown extends StatelessWidget {
  DepartmentDropDown({super.key});
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final AddCoursesController registerController =
      Get.find<AddCoursesController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = registerController.dropDownDepartmentOptions.toList();
      return DropdownSearch<DepartmentModel>.multiSelection(
        key: dropDownKey,
        // 1) Tell it how to find your items (even if it’s instant)
        items: (_, _) => list,

        // 2) How to render each item in the text field & list
        itemAsString: (item) => item.deptName,

        // 3) How to compare objects (required for non-primitive T)
        compareFn: (DepartmentModel a, DepartmentModel b) =>
            a.deptId == b.deptId,

        // 4) Your current selection, if any
        selectedItems: registerController.selectedDepartments,

        onChanged: (List<DepartmentModel> selections) {
          registerController.selectedDepartments.assignAll(selections);
          registerController.changePrograms();
        },

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Department :',
            hintText: 'Select Department',
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

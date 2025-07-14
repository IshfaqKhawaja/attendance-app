import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Local Imports
import '../../models/department_model.dart';
import '../../constants/text_styles.dart';
import '../controllers/register_controller.dart';

class DepartmentDropDown extends StatelessWidget {
  DepartmentDropDown({super.key});
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final RegisterController registerController = Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = registerController.dropDownSelectedDepartments.toList();
      return DropdownSearch<DepartmentModel>(
        key: dropDownKey,
        items: (_, _) => list,

        itemAsString: (item) => item.deptName,

        // 3) How to compare objects (required for non-primitive T)
        compareFn: (DepartmentModel a, DepartmentModel b) =>
            a.deptId == b.deptId,

        // 4) Your current selection, if any
        selectedItem: registerController.selectedDepartment.value,

        onChanged: (DepartmentModel? sel) {
          if (sel != null) {
            registerController.selectedDepartment.value = sel;
          }
        },

        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Department :',
            hintText: 'Select Ypur Department',
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

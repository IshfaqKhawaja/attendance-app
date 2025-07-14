import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Local Imports
import '../../models/faculty_model.dart';
import '../../constants/text_styles.dart';
import '../controllers/add_courses_controller.dart';

/// Multi-select dropdown for Faculties
class FacultyDropDown extends StatelessWidget {
  FacultyDropDown({Key? key}) : super(key: key);
  final dropDownKey = GlobalKey<DropdownSearchState<FacultyModel>>();
  final AddCoursesController registerController =
      Get.find<AddCoursesController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = registerController.faculities.toList();
      return DropdownSearch<FacultyModel>.multiSelection(
        key: dropDownKey,
        items: (_, _) => list,
        selectedItems: registerController.selectedFaculties,
        compareFn: (FacultyModel a, FacultyModel b) => a.factId == b.factId,
        itemAsString: (item) => item.factName,
        onChanged: (List<FacultyModel> selections) {
          registerController.selectedFaculties.assignAll(selections);
          registerController.changeDepartments();
        },
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Faculty :',
            hintText: 'Select Faculty',
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

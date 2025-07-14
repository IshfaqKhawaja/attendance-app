import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Local Imports:
import '../../models/faculty_model.dart';
import '../../constants/text_styles.dart';
import '../controllers/register_controller.dart';

class FacultyDropDown extends StatelessWidget {
  FacultyDropDown({super.key});
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final RegisterController registerController = Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var list = registerController.faculties;
      return DropdownSearch<FacultyModel>(
        key: dropDownKey,

        selectedItem: registerController.selectedFaculty.value,
        items: (_, _) => list,
        compareFn: (FacultyModel a, FacultyModel b) => a.factId == b.factId,
        itemAsString: (item) => item.factName,
        onChanged: (FacultyModel? value) {
          if (value != null) {
            registerController.selectedFaculty.value = value;
            registerController.changeDropDownSelectedDepartments();
          }
        },
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Faculty :',
            hintText: 'Select Your Faculty',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.blue, width: 1.0),
            ),
          ),
          baseStyle: dropDownTextStyle,
        ),
        popupProps: PopupProps.menu(
          fit: FlexFit.loose,
          constraints: BoxConstraints(),
        ),
      );
    });
  }
}

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Local Imports:
import '../../constants/text_styles.dart';
import '../controllers/register_controller.dart';

class TeacherTypeDropDown extends StatelessWidget {
  TeacherTypeDropDown({super.key});
  final dropDownKey = GlobalKey<DropdownSearchState>();
  final RegisterController registerController = Get.find<RegisterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var list = registerController.teacherType;
      return DropdownSearch<String>(
        key: dropDownKey,

        selectedItem: registerController.teacherTypeSelected.value,
        items: (_, _) => List<String>.from(list),
        onChanged: (String? value) {
          if (value != null) {
            registerController.teacherTypeSelected.value = value;
          }
        },
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: 'Teacher Type:',
            hintText: 'Teacher Type',
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

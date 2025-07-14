import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Local Imports:
import '../controllers/register_controller.dart';

class NameInputWidget extends StatelessWidget {
  NameInputWidget({super.key});
  final RegisterController registerController = Get.find<RegisterController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TextField(
        controller: registerController.nameController,
        decoration: InputDecoration(
          labelText: 'Your Name',
          hintText: 'Enter your name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          errorText: registerController.teacherNameError.value,
        ),
        onChanged: (val) {
          // registerController.teacherName.value = val;
          registerController.validateTeacherName(val);
        },
      );
    });
  }
}

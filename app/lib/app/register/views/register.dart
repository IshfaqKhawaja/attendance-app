import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Local Imports:
import '../widgets/teacher_type_drop_down.dart';
import '../../constants/text_styles.dart';
import '../widgets/name_input_field.dart';
import '../widgets/department_drop_down.dart';
import '../widgets/faculty_drop_down.dart';
import '../controllers/register_controller.dart';

class RegisterTeacher extends StatelessWidget {
  const RegisterTeacher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RegisterController registerController = Get.put(
      RegisterController(),
      permanent: true,
    );
    final sizedBox = const SizedBox(height: 20);
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: Get.width * 0.99,
        height: Get.height * 0.52,
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            sizedBox,
            Text("Register Yourself", style: textStyle),
            sizedBox,
            FacultyDropDown(),
            sizedBox,
            DepartmentDropDown(),
            sizedBox,
            TeacherTypeDropDown(),
            sizedBox,
            NameInputWidget(),
            sizedBox,
            Obx(() {
              registerController.teacherNameError.value;
              return ElevatedButton(
                onPressed: () {
                  registerController.registerTeacher();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: Text("Register", style: buttonTextStyle),
              );
            }),
          ],
        ),
      ),
    );
  }
}

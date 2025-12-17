// lib/app/index/views/bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/teacher_bottom_bar_controller.dart';

class TeacherBottomBar extends StatelessWidget {
  TeacherBottomBar({super.key});
  final TeacherBottomBarController controller = Get.put(TeacherBottomBarController());
  @override
  Widget build(BuildContext context) {
    final selectedColor = Get.theme.primaryColor;
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.houseUser,
              color: selectedColor,
            ),
            onPressed: () => controller.changeIndex(0),
          ),
        ],
      ),
    );
  }
}

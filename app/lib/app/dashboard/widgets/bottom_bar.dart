// lib/app/index/views/bottom_bar.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/bottom_bar_controller.dart';

class BottomBar extends StatelessWidget {
  BottomBar({super.key});
  final BottomBarController controller = Get.put(BottomBarController());
  @override
  Widget build(BuildContext context) {
    final selectedColor = Get.theme.primaryColor.withOpacity(1);
    final unSelectedColor = Get.theme.unselectedWidgetColor;
    return Obx(() {
      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.homeUser,
                // 5) Use the reactive value to change color/state
                color: controller.currentIndex.value == 0
                    ? selectedColor
                    : unSelectedColor,
              ),
              onPressed: () => controller.changeIndex(0),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.addressCard,
                color: controller.currentIndex.value == 1
                    ? selectedColor
                    : unSelectedColor,
              ),
              onPressed: () => controller.changeIndex(1),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.userFriends,
                color: controller.currentIndex.value == 2
                    ? selectedColor
                    : unSelectedColor,
              ),
              onPressed: () => controller.changeIndex(2),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.cog,
                color: controller.currentIndex.value == 3
                    ? selectedColor
                    : unSelectedColor,
              ),
              onPressed: () => controller.changeIndex(3),
            ),
          ],
        ),
      );
    });
  }
}

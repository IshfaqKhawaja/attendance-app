


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/hod_bottom_bar_controller.dart';


class HODBottomBar extends StatelessWidget {
  HODBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller - it's guaranteed to be initialized by HodDashboard
    final controller = Get.find<HodBottomBarController>();

    return Obx(() => BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              size: 30,
              color: controller.currentIndex.value == 0
                  ? Get.theme.primaryColor
                  : Colors.grey,
            ),
            onPressed: () => controller.changeIndex(0),
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              size: 30,
              color: controller.currentIndex.value == 1
                  ? Get.theme.primaryColor
                  : Colors.grey,
            ),
            onPressed: () => controller.changeIndex(1),
          ),
        ],
      ),
    ));
  }
}
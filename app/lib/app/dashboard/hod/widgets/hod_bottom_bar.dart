


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/hod_bottom_bar_controller.dart';


class HODBottomBar extends StatelessWidget {
  HODBottomBar({super.key});
  final HodBottomBarController controller = Get.put(HodBottomBarController());

  Icon iconFunction(IconData iconData, int  index) {
    return Icon(
      iconData, size: 30, 
      color: controller.currentIndex.value == index ? Get.theme.primaryColor : Colors.grey,
    );
  }
 void onPressed(int index) {
    controller.changeIndex(index);
  }
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: iconFunction(Icons.home, 0),
            onPressed: () {
              onPressed(0);
            },
          ),
          IconButton(
            icon: iconFunction(Icons.person, 1),
            onPressed: () {
              onPressed(1);
            },
          ),
        ],
      ),
    );
  }
}
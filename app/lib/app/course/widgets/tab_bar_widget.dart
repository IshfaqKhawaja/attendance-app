import 'package:app/app/course/controllers/tab_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabBarWidget extends StatelessWidget {
  final tabs;
  TabBarWidget({super.key, required this.tabs});
  final TabBarController tabBarController = Get.put(TabBarController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      tabBarController.initialIndex.value;
      return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: TabBarView(children: tabs),
      );
    });
  }
}

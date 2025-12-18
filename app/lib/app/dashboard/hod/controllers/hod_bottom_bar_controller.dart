import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/programs.dart';
import '../views/manage_teachers.dart';
import '../controllers/manage_teachers_controller.dart';

class HodBottomBarController extends GetxController{
  var currentIndex = 0.obs;

  // Screens are initialized lazily after onInit registers the controllers
  late final List<Widget> screens;

  @override
  void onInit() {
    super.onInit();
    // Pre-register ManageTeachersController to ensure it's available
    // before TeacherCard widgets try to find it (especially during hot reload)
    Get.put(ManageTeachersController(), permanent: true);

    // Initialize screens after controllers are registered
    screens = [
      Programs(),
      ManageTeachers(),
    ];
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  /// Reload teachers data (called when navigating to a different department)
  void reloadTeachers() {
    if (Get.isRegistered<ManageTeachersController>()) {
      Get.find<ManageTeachersController>().loadTeachers();
    }
  }
}
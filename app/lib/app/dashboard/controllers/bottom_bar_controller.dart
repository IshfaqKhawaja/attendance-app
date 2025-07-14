import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
// Local Imports
import '../../add_courses/views/add_courses.dart';
import '../widgets/home_widget.dart';

class BottomBarController extends GetxController {
  var currentIndex = 0.obs;
  var screens = [HomeWidget(), AddCourses(), SizedBox(), SizedBox()];
  void changeIndex(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
// Local Imports
import '../views/home_widget.dart';

class TeacherBottomBarController extends GetxController {
  var currentIndex = 0.obs;
  var screens = [HomeWidget(), SizedBox()];
  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

import 'package:app/app/dashboard/hod/views/manage_teachers.dart';

import '../views/programs.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HodBottomBarController extends GetxController{
  var currentIndex = 0.obs;
  var screens = [
    Programs(),
    ManageTeachers(),
    SizedBox(),
  ];
  void changeIndex(int index) {
    currentIndex.value = index;  
  }
}
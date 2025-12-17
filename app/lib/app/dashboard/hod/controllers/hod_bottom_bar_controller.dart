import 'package:app/app/dashboard/hod/views/manage_teachers.dart';
import 'package:get/get.dart';

import '../views/programs.dart';

class HodBottomBarController extends GetxController{
  var currentIndex = 0.obs;
  var screens = [
    Programs(),
    ManageTeachers(),
  ];
  void changeIndex(int index) {
    currentIndex.value = index;  
  }
}
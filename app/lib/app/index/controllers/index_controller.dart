import 'package:get/get.dart';

class IndexController extends GetxController {
  var index = 0.obs;

  void tap(int i) {
    switch (i) {
      case 0:
        Get.toNamed('/add_students');
        break;
      case 1:
        Get.toNamed('/add_attendence');
        break;
      default:
        Get.toNamed('/index_page');
    }
  }
}

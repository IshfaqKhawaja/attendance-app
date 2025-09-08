import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class IndexController extends GetxController {
  var index = 0.obs;

  void tap(int i) {
    switch (i) {
      case 0:
  Get.toNamed(Routes.ADD_STUDENTS);
        break;
      case 1:
  // TODO: replace with actual route when attendance feature is added
  Get.toNamed(Routes.INDEX_PAGE);
        break;
      default:
  Get.toNamed(Routes.INDEX_PAGE);
    }
  }
}

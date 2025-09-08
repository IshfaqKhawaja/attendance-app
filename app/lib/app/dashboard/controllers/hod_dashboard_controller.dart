
import 'package:app/app/models/program_model.dart';
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:get/get.dart';

class HodDashboardController extends GetxController {
  final singInController = Get.find<SignInController>();
  final LoadingController loadingController = Get.find<LoadingController>();
  RxList<ProgramModel> programs = <ProgramModel>[].obs;
  RxBool isLoading = false.obs;
  RxString? errorMessage = RxString('');

  void loadPrograms() {
    try {
      isLoading.value = true;
      errorMessage?.value = '';
      final deptId = singInController.userData.value.deptId;
      programs.value = loadingController.programs
          .where((program) => program.deptId == deptId)
          .toList();
    } catch (e) {
      errorMessage?.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }


  
  
  @override
  void onInit() {
    super.onInit();
  loadPrograms();
  ever(loadingController.programs, (_) => loadPrograms());
  ever(singInController.userData, (_) => loadPrograms());
  }
}

// json/http calls moved into repository
import 'package:app/app/loading/controllers/loading_controller.dart';
import 'package:app/app/models/teacher_course.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:get/get.dart';
// no direct http after refactor
import '../../core/network/api_client.dart';
import '../../core/repositories/teacher_repository.dart';

class TeacherDashboardController extends GetxController {
  final singInController = Get.find<SignInController>();
  final loadingController = Get.find<LoadingController>();
  final isTeacherCoursesLoaded = false.obs;
  RxList<TeacherCourseModel> thisTeacherCourses = <TeacherCourseModel>[].obs;
  late final ApiClient _apiClient;
  late final TeacherRepository _repo;

  void loadTeacherCourses() async {
    isTeacherCoursesLoaded.value = false;
    try {
      final res = await _repo.listTeacherCourses(
          singInController.teacherData.value.teacherId);
      if (res['success'] == true) {
        thisTeacherCourses.value = (res['teacher_courses'] as List<dynamic>)
            .map((e) => TeacherCourseModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      Get.snackbar('ERROR', 'Failed to load courses: $e');
    }
    isTeacherCoursesLoaded.value = true;
  }

  void attendanceNotifier() async {
    try {
      final res = await _repo.attendanceNotifier();
      if (res['success'] != true) {
        Get.snackbar('ERROR', 'Error Sending SMS');
      }
    } catch (e) {
      Get.snackbar('ERROR', 'Error Sending SMS');
    }
  }

  @override
  void onInit() {
    super.onInit();
  _apiClient = ApiClient();
  _repo = TeacherRepository(_apiClient);
    loadTeacherCourses();
  }
}

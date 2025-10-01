import 'package:app/app/core/controllers/base_controller.dart';
import 'package:app/app/core/network/api_client.dart';
import 'package:app/app/models/teacher_course.dart';
import 'package:app/app/signin/controllers/signin_controller.dart';
import 'package:app/app/core/network/endpoints.dart';
import 'package:app/app/core/repositories/teacher_repository.dart';
import 'package:get/get.dart';

class TeacherDashboardController extends BaseController {
  late final SignInController _signInController;
  late final TeacherRepository _teacherRepository;
  late final ApiClient _apiClient;

  final RxList<TeacherCourseModel> teacherCourses = <TeacherCourseModel>[].obs;
  final RxBool isCoursesLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    loadTeacherCourses();
  }

  void _initializeDependencies() {
    _signInController = Get.find<SignInController>();
    _apiClient = ApiClient();
    _teacherRepository = TeacherRepository(_apiClient);
  }

  /// Load teacher courses from API
  Future<void> loadTeacherCourses() async {
    isCoursesLoaded.value = false;
    
    await handleAsync(() async {
      final teacherId = _signInController.teacherData.value.teacherId;
      if (teacherId.isEmpty) {
        throw Exception('Teacher ID not found');
      }

      final response = await _apiClient.getJson(
        Endpoints.teacherCourses(teacherId)
      );

      if (response['success'] == true) {
        teacherCourses.value = (response['teacher_courses'] as List<dynamic>)
            .map((e) => TeacherCourseModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load courses');
      }
    });
    
    isCoursesLoaded.value = true;
  }

  /// Send attendance notification SMS
  Future<void> sendAttendanceNotification() async {
    await handleAsync(() async {
      final result = await _teacherRepository.attendanceNotifier();
      
      if (result['success'] != true) {
        throw Exception('Failed to send SMS notification');
      }
      
      showSuccessSnackbar('Attendance notification sent successfully');
    });
  }

  /// Refresh teacher courses
  Future<void> refreshCourses() async {
    await loadTeacherCourses();
  }

  /// Get courses count
  int get coursesCount => teacherCourses.length;

  /// Check if teacher has courses
  bool get hasCourses => teacherCourses.isNotEmpty;

  /// Get teacher ID
  String? get teacherId => _signInController.teacherData.value.teacherId;
}

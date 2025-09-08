import '../network/api_client.dart';
import '../network/endpoints.dart';

class TeacherRepository {
  final ApiClient api;
  TeacherRepository(this.api);

  Future<Map<String, dynamic>> listTeacherCourses(String teacherId) async {
    return api.postJson('${Endpoints.baseUrl}/teacher_course/display', {
      'teacher_id': teacherId,
    });
  }

  Future<Map<String, dynamic>> attendanceNotifier() async {
    // Using getJson to keep parity with existing endpoint
    return api.getJson('${Endpoints.baseUrl}/attendance_notifier/notify');
  }
}

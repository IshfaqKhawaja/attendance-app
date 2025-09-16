import 'dart:typed_data';

import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class CourseRepository {
  final ApiClient api;
  CourseRepository(this.api);

  Future<Map<String, dynamic>> listStudentsByCourse(String courseId) async {
    return api.postJson(
      '${Endpoints.baseUrl}/course_students/display_students_by_ids',
      {'course_id': courseId},
    );
  }

  Future<Map<String, dynamic>> addStudentsToCourse(
    List<Map<String, dynamic>> students,
    List<Map<String, dynamic>> courseStudents,
  ) async {
    return api.postJson(
      '${Endpoints.baseUrl}/course_students/add_students_to_course',
      {
        'students': students,
        'course_students': courseStudents,
      },
    );
  }

  Future<Map<String, dynamic>> addCourse(String name, String semId) async {
    return api.postJson(
      '${Endpoints.baseUrl}/course/add',
      {
        'name': name,
        'sem_id': semId,
      },
    );
  }

  // Future<Uint8List> generateCourseReport(
  //   String courseId,
  //   String startDate,
  //   String endDate,
  // ) async {
  //   return api.postBytes(
  //     '${Endpoints.baseUrl}/course_students/generate_report',
  //     {
  //       'course_id': courseId,
  //       'start_date': startDate,
  //       'end_date': endDate,
  //     },
  //   );
  // }

  Future<Uint8List> generateCourseReportXlsx(
    String courseId,
    String startDate,
    String endDate,
    String filePath,
  ) async {
    return api.postBytes(
      '${Endpoints.baseUrl}/reports/generate_course_report',
      {
        'course_id': courseId,
        'start_date': startDate,
        'end_date': endDate,
        'file_path': filePath,
      },
    );
  }
}

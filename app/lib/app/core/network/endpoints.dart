import '../../config/environment.dart';

class Endpoints {
  Endpoints._();

  // Get base URL from environment configuration
  static String get baseUrl => AppConfig.current.apiBaseUrl;

  // Authentication endpoints
  static const String sendOtp = '/authenticate/send_otp';
  static const String verifyOtp = '/authenticate/verify_otp';
  static const String registerTeacher = '/authenticate/register_teacher';
  static const String checkUser = '/authenticate/check_user';

  // Initial/Setup endpoints
  static const String getAllData = '/initial/get_all_data';

  // Semester endpoints
  static String deleteSemester(String semId) => '$baseUrl/semester/delete/$semId';
  static String displaySemesterByProgramId(String progId) => '$baseUrl/semester/display_semester_by_program_id/$progId';
  static const String addSemester = '/semester/add';
  static String editSemester(String semId) => '$baseUrl/semester/edit/$semId';

  // Teacher endpoints
  static String displayTeacherByDeptId(String deptId) => '$baseUrl/teacher/display/$deptId';
  static String getTeachersByDeptId(String deptId) => '$baseUrl/teacher/display/$deptId';
  static const String addTeacher = '/teacher/add';
  static const String deleteTeacher = '/teacher/delete';
  static const String editTeacher = '/teacher/edit';

  // Course endpoints
  static const String addCourse = '/course/add';
  static const String editCourse = '/course/edit';
  static String displayCoursesBySemesterId(String semId) => '$baseUrl/course/display_courses_by_semester_id/$semId';
  static String deleteCourseById(String courseId) => '$baseUrl/course/delete/$courseId';

  // Teacher-Course endpoints
  static String teacherCourses(String teacherId) => '$baseUrl/teacher_course/display/$teacherId';

  // Student enrollment endpoints
  static const String addStudentsFromFile = '/student_enrollment/upload_bulk_enrollment_file';
  static String getStudentsBySemId(String semId) => '$baseUrl/student_enrollment/display_by_sem_id/$semId';
  static String getStudentsByCourseId(String courseId) => '$baseUrl/student_enrollment/fetch_students/$courseId';
  static const String deleteStudentById = '/student_enrollment/delete_student_enrollment';
  static const String addStudent = '/student/add';
  static const String addStudentEnrollment = '/student_enrollment/add';
  static const String editStudent = '/student/edit';

  // Attendance endpoints
  static const String addAttendanceBulk = '/attendance/add_attendence_bulk';
  static const String updateAttendanceBulk = '/attendance/update-bulk';
  static String getAttendanceForDate(String courseId, String date) =>
      '$baseUrl/attendance/course/$courseId/$date';
  static String getLastWorkingDay(String courseId) =>
      '$baseUrl/attendance/last-working-day/$courseId';
  static String getAttendanceHistory(String courseId, String startDate, String endDate) =>
      '$baseUrl/attendance/history/$courseId?start_date=$startDate&end_date=$endDate';

  // Report endpoints
  static const String generateCourseReport = '/reports/generate_course_report_xls';
  static const String generateAttendanceReport = '/reports/generate_course_report_pdf';
  static const String generateAttendanceReportBySemId = '/reports/generate_report_by_sem_id_xls';

  // Notification endpoints
  static const String sendAttendanceSms = '/attendance_notifier/notify';

  // Helper method to get full URL
  static String fullUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return path.startsWith('/') ? '$baseUrl$path' : '$baseUrl/$path';
  }
}

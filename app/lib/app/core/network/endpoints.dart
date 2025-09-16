class Endpoints {
  Endpoints._();


  static const String baseUrl = "http://localhost:8000";

  // Group endpoints here
  static String deleteSemester(String semId) => "$baseUrl/semester/delete/$semId";
  static String displaySemesterByProgramId(String progId) => "$baseUrl/semester/display_semester_by_program_id/$progId";
  static const String getAllData = "$baseUrl/initial/get_all_data";
  static const String addSemester = "$baseUrl/semester/add";
  static String editSemester(String semId) => "$baseUrl/semester/edit/$semId";
  static String displayTeacherByDeptId(String deptId) => "$baseUrl/teacher/display/$deptId";
  static String addTeacher = "$baseUrl/teacher/add";
  static String deleteTeacher =  "$baseUrl/teacher/delete";
  static String editTeacher = "$baseUrl/teacher/edit";
  static String addCourse = "$baseUrl/course/add";
  static String displayCoursesBySemesterId(String semId) => "$baseUrl/course/display_courses_by_semester_id/$semId";
  static String generateCourseReport = "$baseUrl/reports/generate_course_report";
  static String deleteCourseById(String courseId) => "$baseUrl/course/delete/$courseId";
  static String addStudentsFromFile = "$baseUrl/student_enrollment/upload_bulk_enrollment_file";
  static String getStudentsBySemId(String semId) => "$baseUrl/student_enrollment/display_by_sem_id/$semId";
  static String getTeachersByDeptId(String deptId) => "$baseUrl/teacher/display/$deptId";
  static String teacherCourses(String teacherId) => "$baseUrl/teacher_course/display/$teacherId";
  static String getStudentsByCourseId(String courseId) => "$baseUrl/student_enrollment/fetch_students/$courseId";
  static String addAttendanceBulk = "$baseUrl/attendance/add_attendence_bulk";
  static String generateAttendanceReport = "$baseUrl/attendance/generate_report";

}
  
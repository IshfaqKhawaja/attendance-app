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
}

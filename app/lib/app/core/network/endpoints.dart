class Endpoints {
  Endpoints._();


  static const String baseUrl = "http://localhost:8000";

  static String deleteSemester(String semId) => "$baseUrl/semester/delete/$semId";
  static String displaySemesterByProgramId(String progId) => "$baseUrl/semester/display_semester_by_program_id/$progId";
  // Group endpoints here
  static const String getAllData = "$baseUrl/initial/get_all_data";
  static const String addSemester = "$baseUrl/semester/add";
}

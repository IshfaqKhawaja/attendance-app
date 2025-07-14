class CourseModel {
  final String courseId;
  final String courseName;
  final String semId;
  final String progId;
  final String deptId;
  final String factId;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.semId,
    required this.progId,
    required this.deptId,
    required this.factId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json["course_id"],
      courseName: json["course_name"],
      semId: json["sem_id"],
      progId: json["prog_id"],
      deptId: json["dept_id"],
      factId: json["fact_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "course_id": courseId,
      "course_name": courseName,
      "sem_id": semId,
      "prog_id": progId,
      "dept_id": deptId,
      "fact_id": factId,
    };
  }
}

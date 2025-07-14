class CourseStudentsModel {
  final String studentId;
  final String courseId;
  final String progId;
  final String semId;
  final String deptId;

  CourseStudentsModel({
    required this.studentId,
    required this.courseId,
    required this.progId,
    required this.deptId,
    required this.semId,
  });

  factory CourseStudentsModel.fromJson(Map<String, dynamic> json) {
    return CourseStudentsModel(
      studentId: json["student_id"],
      courseId: json["course_id"],
      progId: json["prog_id"],
      deptId: json["dept_id"],
      semId: json["sem_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      "course_id": courseId,
      "prog_id": progId,
      "sem_id": semId,
      "dept_id": deptId,
    };
  }
}

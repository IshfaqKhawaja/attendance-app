class TeacherCourseModel {
  final String teacherId;
  final String courseId;
  final String? courseName;
  final String semId;
  final String? semName;
  final String progId;
  final String? progName;

 

  TeacherCourseModel({
    required this.teacherId,
    required this.courseId,
    required this.semId,
    required this.progId,
    this.courseName,
    this.progName,
    this.semName,
  });

  factory TeacherCourseModel.fromJson(Map<String, dynamic> json) {
    return TeacherCourseModel(
      teacherId: json["teacher_id"],
      courseId: json["course_id"],
      courseName: json["course_name"],
      semId: json["sem_id"],
      semName: json["sem_name"],
      progId: json["prog_id"],
      progName: json["prog_name"],
    );
  }
}

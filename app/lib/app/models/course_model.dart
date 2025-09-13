class CourseModel {
  final String courseId;
  final String courseName;
  final String semId;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.semId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json["course_id"],
      courseName: json["course_name"],
      semId: json["sem_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "course_id": courseId,
      "course_name": courseName,
      "sem_id": semId,
    };
  }
}

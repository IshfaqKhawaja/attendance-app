class UserModel {
  final String teacherId;
  final String teacherName;
  final String type;
  final String deptId;
  UserModel({
    required this.teacherId,
    required this.teacherName,
    required this.type,
    required this.deptId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      teacherId: json["teacher_id"],
      teacherName: json["name"],
      type: json["type"],
      deptId: json["dept_id"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "teacher_id": teacherId,
      "name": teacherName,
      "type": type,
      "dept_id": deptId,
    };
  }
}

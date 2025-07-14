class RegisterModel {
  final String teacherId;
  final String teacherName;
  final String type;
  final String deptId;

  RegisterModel({
    required this.teacherId,
    required this.teacherName,
    required this.type,
    required this.deptId,
  });
  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      teacherId: json['teacher_id'],
      teacherName: json["teacher_name"],
      type: json["type"],
      deptId: json["dpet_id"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'name': teacherName,
      'dept_id': deptId,
      'type': type,
    };
  }
}

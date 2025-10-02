import '../../core/enums/teacher_type.dart';

class TeacherModel {
  final String teacherId;
  final String teacherName;
  final String type;
  final String deptId;
  
  TeacherModel({
    required this.teacherId,
    required this.teacherName,
    required this.type,
    required this.deptId,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      teacherId: json["teacher_id"],
      teacherName: json["teacher_name"],
      type: json["type"],
      deptId: json["dept_id"],
    );
  }
  
  /// Get teacher type as enum
  TeacherType get employmentType => TeacherType.fromString(type);
  Map<String, dynamic> toJson() {
    return {
      "teacher_id": teacherId,
      "teacher_name": teacherName,
      "type": type,
      "dept_id": deptId,
    };
  }
}

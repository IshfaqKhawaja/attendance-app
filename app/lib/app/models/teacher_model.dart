


class Teacher {
  final String teacher_id;
  final String teacher_name;
  final String type;
  final String deptId;

  Teacher({required this.teacher_id, required this.teacher_name, required this.type, required this.deptId});


  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      teacher_id: json['teacher_id'],
      teacher_name: json['teacher_name'],
      type: json['type'],
      deptId: json['dept_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacher_id,
      'teacher_name': teacher_name,
      'type': type,
      'dept_id': deptId,
    };
  }
}
class StudentModel {
  final String studentId;
  final String studentName;
  final int phoneNumber;
  final String progId;
  final String semId;
  final String deptId;

  StudentModel({
    required this.studentId,
    required this.studentName,
    required this.phoneNumber,
    required this.progId,
    required this.semId,
    required this.deptId,
  });
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      studentId: json["student_id"],
      studentName: json["student_name"],
      phoneNumber: json["phone_number"],
      progId: json["prog_id"],
      semId: json["sem_id"],
      deptId: json["dept_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      "student_name": studentName,
      "phone_number": phoneNumber,
      "prog_id": progId,
      "sem_id": semId,
      "dept_id": deptId,
    };
  }
}

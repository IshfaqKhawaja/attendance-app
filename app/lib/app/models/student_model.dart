class StudentModel {
  final String studentId;
  final String studentName;
  final String phoneNumber; // keep as string to avoid locale/format issues

  StudentModel({
    required this.studentId,
    required this.studentName,
    required this.phoneNumber,
  });
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final phone = json["phone_number"];
    return StudentModel(
      studentId: json["student_id"],
      studentName: json["student_name"],
      phoneNumber: phone is int ? phone.toString() : (phone?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      "student_name": studentName,
      "phone_number": phoneNumber,
    };
  }

  StudentModel copyWith({
    String? studentId,
    String? studentName,
    String? phoneNumber,
    String? progId,
    String? semId,
    String? deptId,
  }) {
    return StudentModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentModel &&
        other.studentId == studentId &&
        other.studentName == studentName &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => Object.hash(studentId, studentName, phoneNumber);
}



class StudentInSemModel {
  final String studentId;
  final String studentName;
  final String phoneNumber; // keep as string to avoid locale/format issues
  final String semId;

  StudentInSemModel({
    required this.studentId,
    required this.studentName,
    required this.phoneNumber,
    required this.semId,
  });
  factory StudentInSemModel.fromJson(Map<String, dynamic> json) {
    final phone = json["phone_number"];
    return StudentInSemModel(
      studentId: json["student_id"],
      studentName: json["student_name"],
      phoneNumber: phone is int ? phone.toString() : (phone?.toString() ?? ''),
      semId: json["sem_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      "student_name": studentName,
      "phone_number": phoneNumber,
      "sem_id": semId,
    };
  }

  StudentInSemModel copyWith({
    String? studentId,
    String? studentName,
    String? phoneNumber,
    String? semId,
  }) {
    return StudentInSemModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      semId: semId ?? this.semId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentInSemModel &&
        other.studentId == studentId &&
        other.studentName == studentName &&
        other.phoneNumber == phoneNumber &&
        other.semId == semId;
  }

  @override
  int get hashCode => Object.hash(studentId, studentName, phoneNumber, semId);
}
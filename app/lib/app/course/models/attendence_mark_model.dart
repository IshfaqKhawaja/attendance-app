class AttendenceMarkModel {
  final String attendanceId;
  final String studentId;
  final String courseId;
  final DateTime date;
  final bool present;
  final String semId;
  final String deptId;
  final String progId;

  AttendenceMarkModel({
    required this.attendanceId,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.present,
    required this.semId,
    required this.deptId,
    required this.progId,
  });

  factory AttendenceMarkModel.fromJson(Map<String, dynamic> json) {
    return AttendenceMarkModel(
      attendanceId: json['attendance_id'],
      studentId: json['studentI_id'],
      courseId: json['course_id'],
      date: DateTime.parse(json['date']),
      present: json['present'],
      semId: json['sem_id'],
      deptId: json['dept_id'],
      progId: json['prog_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'course_id': courseId,
      'date': date.toIso8601String(),
      'present': present,
      'sem_id': semId,
      'dept_id': deptId,
      'prog_id': progId,
    };
  }
}

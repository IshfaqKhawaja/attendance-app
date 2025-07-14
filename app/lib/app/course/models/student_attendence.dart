class StudentAttendance {
  final String studentId;
  final String studentName;
  final String courseId;
  final String semId;
  final DateTime date;
  final String deptId;
  final String progId;
  final List<bool> marked;

  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.semId,
    required this.date,
    required this.deptId,
    required this.progId,
    required this.marked,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['studentId'],
      studentName: json['studentName'],
      courseId: json['courseId'],
      semId: json['semId'],
      date: DateTime.parse(json['date']),
      deptId: json['deptId'],
      progId: json['progId'],
      marked: List<bool>.from(json['marked']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'course_id': courseId,
      'sem_id': semId,
      'date': date.toIso8601String(),
      'dept_id': deptId,
      'prog_id': progId,
      'marked': marked,
    };
  }

  // Optional: copyWith to update selectively
  StudentAttendance copyWith({
    String? studentId,
    String? studentName,
    String? courseId,
    String? semId,
    DateTime? date,
    String? deptId,
    String? progId,
    List<bool>? marked,
  }) {
    return StudentAttendance(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      courseId: courseId ?? this.courseId,
      semId: semId ?? this.semId,
      date: date ?? this.date,
      deptId: deptId ?? this.deptId,
      progId: progId ?? this.progId,
      marked: marked ?? List<bool>.from(this.marked),
    );
  }
}

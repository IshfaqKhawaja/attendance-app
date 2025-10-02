class StudentAttendanceList {
  final String studentId;
  final String studentName;
  final String courseId;
  final DateTime date;
  final List<bool> marked;

  StudentAttendanceList({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.date,
    required this.marked,
  });

  factory StudentAttendanceList.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceList(
      studentId: json['studentId'],
      studentName: json['studentName'],
      courseId: json['courseId'],
      date: DateTime.parse(json['date']),
      marked: List<bool>.from(json['marked']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'course_id': courseId,
      'date': date.toIso8601String(),
      'marked': marked,
    };
  }

  // Optional: copyWith to update selectively
  StudentAttendanceList copyWith({
    String? studentId,
    String? studentName,
    String? courseId,
    DateTime? date,
    List<bool>? marked,
  }) {
    return StudentAttendanceList(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      marked: marked ?? this.marked,
    );
  }
}


class StudentAttendance {
  final String studentId;
  final String studentName;
  final String courseId;
  final DateTime date;
  final bool present;
  final int? slotNumber; // Slot number for multiple attendance per day (1, 2, 3...)
  
  StudentAttendance({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.date,
    required this.present,
    this.slotNumber,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['studentId'],
      studentName: json['studentName'],
      courseId: json['courseId'],
      date: DateTime.parse(json['date']),
      present: json['present'],
      slotNumber: json['slot_number'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'student_id': studentId,
      'student_name': studentName,
      'course_id': courseId,
      'date': date.toIso8601String(),
      'present': present,
    };
    
    // Only include slot_number if it's not null
    if (slotNumber != null) {
      json['slot_number'] = slotNumber;
    }
    
    return json;
  }
  

}

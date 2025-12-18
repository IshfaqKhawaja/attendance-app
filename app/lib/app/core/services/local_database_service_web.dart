import 'package:get/get.dart';

/// Web implementation of local database using in-memory storage
/// SQLite is not supported on web, so we use a simple in-memory Map
class LocalDatabaseImpl {
  // In-memory storage for web
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'students': [],
    'attendance': [],
    'courses': [],
    'sync_queue': [],
  };

  int _syncQueueId = 0;

  Future<void> initialize() async {
    Get.log('Web Database initialized (in-memory storage)');
    Get.log('Note: Data will not persist across page refreshes on web');
  }

  // Student operations
  Future<void> insertStudent(Map<String, dynamic> student) async {
    student['created_at'] = DateTime.now().millisecondsSinceEpoch;
    student['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    student['synced'] = 0;

    final students = _tables['students']!;
    final existingIndex = students.indexWhere((s) => s['student_id'] == student['student_id']);

    if (existingIndex >= 0) {
      students[existingIndex] = student;
    } else {
      students.add(student);
    }
    Get.log('Student inserted: ${student['student_id']}');
  }

  Future<List<Map<String, dynamic>>> getStudents({String? courseId}) async {
    final students = _tables['students']!;
    if (courseId != null) {
      return students.where((s) =>
        (s['course_ids'] as String?)?.contains(courseId) ?? false
      ).toList();
    }
    return List.from(students);
  }

  Future<Map<String, dynamic>?> getStudent(String studentId) async {
    final students = _tables['students']!;
    try {
      return students.firstWhere((s) => s['student_id'] == studentId);
    } catch (e) {
      return null;
    }
  }

  // Attendance operations
  Future<void> insertAttendance(Map<String, dynamic> attendance) async {
    attendance['created_at'] = DateTime.now().millisecondsSinceEpoch;
    attendance['synced'] = 0;

    final attendanceList = _tables['attendance']!;
    final existingIndex = attendanceList.indexWhere((a) => a['id'] == attendance['id']);

    if (existingIndex >= 0) {
      attendanceList[existingIndex] = attendance;
    } else {
      attendanceList.add(attendance);
    }
    Get.log('Attendance inserted: ${attendance['student_id']} - ${attendance['date']}');
  }

  Future<void> insertBulkAttendance(List<Map<String, dynamic>> attendanceList) async {
    for (final attendance in attendanceList) {
      await insertAttendance(attendance);
    }
    Get.log('Bulk attendance inserted: ${attendanceList.length} records');
  }

  Future<List<Map<String, dynamic>>> getAttendance({
    String? studentId,
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var result = List<Map<String, dynamic>>.from(_tables['attendance']!);

    if (studentId != null) {
      result = result.where((a) => a['student_id'] == studentId).toList();
    }

    if (courseId != null) {
      result = result.where((a) => a['course_id'] == courseId).toList();
    }

    if (startDate != null) {
      final startMs = startDate.millisecondsSinceEpoch;
      result = result.where((a) => (a['date'] as int) >= startMs).toList();
    }

    if (endDate != null) {
      final endMs = endDate.millisecondsSinceEpoch;
      result = result.where((a) => (a['date'] as int) <= endMs).toList();
    }

    result.sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));
    return result;
  }

  // Course operations
  Future<void> insertCourse(Map<String, dynamic> course) async {
    course['created_at'] = DateTime.now().millisecondsSinceEpoch;
    course['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    course['synced'] = 0;

    final courses = _tables['courses']!;
    final existingIndex = courses.indexWhere((c) => c['id'] == course['id']);

    if (existingIndex >= 0) {
      courses[existingIndex] = course;
    } else {
      courses.add(course);
    }
    Get.log('Course inserted: ${course['course_name']}');
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    final courses = List<Map<String, dynamic>>.from(_tables['courses']!);
    courses.sort((a, b) => (a['course_name'] as String).compareTo(b['course_name'] as String));
    return courses;
  }

  // Synchronization operations
  Future<void> addToSyncQueue(String tableName, String recordId, String action, Map<String, dynamic> data) async {
    _syncQueueId++;
    _tables['sync_queue']!.add({
      'id': _syncQueueId,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final items = List<Map<String, dynamic>>.from(_tables['sync_queue']!);
    items.sort((a, b) => (a['created_at'] as int).compareTo(b['created_at'] as int));
    return items.take(50).toList();
  }

  Future<void> markAsSynced(String tableName, String recordId) async {
    final table = _tables[tableName];
    if (table != null) {
      final index = table.indexWhere((item) => item['id'] == recordId);
      if (index >= 0) {
        table[index]['synced'] = 1;
      }
    }
  }

  Future<void> removeSyncItem(int syncId) async {
    _tables['sync_queue']!.removeWhere((item) => item['id'] == syncId);
  }

  // Utility operations
  Future<int> getUnsyncedCount(String tableName) async {
    final table = _tables[tableName];
    if (table == null) return 0;
    return table.where((item) => item['synced'] == 0).length;
  }

  Future<void> clearTable(String tableName) async {
    _tables[tableName]?.clear();
    Get.log('Table $tableName cleared');
  }

  Future<void> clearAllData() async {
    _tables['students']!.clear();
    _tables['attendance']!.clear();
    _tables['courses']!.clear();
    _tables['sync_queue']!.clear();
    Get.log('All data cleared from in-memory database');
  }

  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'students': _tables['students']!.length,
      'attendance': _tables['attendance']!.length,
      'courses': _tables['courses']!.length,
      'pendingSync': _tables['sync_queue']!.length,
    };
  }

  void dispose() {
    // Nothing to dispose for in-memory storage
  }
}
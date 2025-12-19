import 'package:get/get.dart';
import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';

/// Model for a single attendance record in history
class HistoryAttendanceRecord {
  final int attendanceId;
  final String studentId;
  final String studentName;
  final String courseId;
  final DateTime date;
  final bool present;
  final int slot;

  HistoryAttendanceRecord({
    required this.attendanceId,
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.date,
    required this.present,
    required this.slot,
  });

  factory HistoryAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return HistoryAttendanceRecord(
      attendanceId: json['attendance_id'] ?? 0,
      studentId: json['student_id'] ?? '',
      studentName: json['student_name'] ?? json['student_id'] ?? '',
      courseId: json['course_id'] ?? '',
      date: DateTime.parse(json['date']),
      present: json['present'] ?? false,
      slot: json['slot'] ?? 1,
    );
  }
}

/// Model for a single day's attendance data
class DayAttendanceData {
  final DateTime date;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int slotsCount; // Number of attendance sessions on this day
  final List<HistoryAttendanceRecord> records;

  DayAttendanceData({
    required this.date,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.slotsCount,
    required this.records,
  });

  factory DayAttendanceData.fromJson(Map<String, dynamic> json) {
    return DayAttendanceData(
      date: DateTime.parse(json['date']),
      totalStudents: json['total_students'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      slotsCount: json['slots_count'] ?? 1,
      records: (json['records'] as List?)
              ?.map((r) => HistoryAttendanceRecord.fromJson(r))
              .toList() ??
          [],
    );
  }

  double get attendancePercentage =>
      totalStudents > 0 ? (presentCount / totalStudents) * 100 : 0;

  /// Get records for a specific slot
  List<HistoryAttendanceRecord> getRecordsForSlot(int slot) {
    return records.where((r) => r.slot == slot).toList();
  }

  /// Group records by student for display
  /// Returns list of students with their attendance across all slots
  List<StudentDayAttendance> get studentsAttendance {
    final Map<String, StudentDayAttendance> grouped = {};

    for (final record in records) {
      if (!grouped.containsKey(record.studentId)) {
        grouped[record.studentId] = StudentDayAttendance(
          studentId: record.studentId,
          studentName: record.studentName,
          slots: [],
        );
      }
      grouped[record.studentId]!.slots.add(SlotAttendance(
        slot: record.slot,
        present: record.present,
        attendanceId: record.attendanceId,
      ));
    }

    // Sort by student name
    final list = grouped.values.toList();
    list.sort((a, b) => a.studentName.compareTo(b.studentName));
    return list;
  }
}

/// Helper class to represent a student's attendance for a day
class StudentDayAttendance {
  final String studentId;
  final String studentName;
  final List<SlotAttendance> slots;

  StudentDayAttendance({
    required this.studentId,
    required this.studentName,
    required this.slots,
  });

  /// Primary attendance status (slot 1)
  bool get isPresent => slots.isNotEmpty && slots.first.present;

  /// Count of slots where student was present
  int get presentSlots => slots.where((s) => s.present).length;

  /// Total slots for this student
  int get totalSlots => slots.length;
}

/// Helper class for individual slot attendance
class SlotAttendance {
  final int slot;
  final bool present;
  final int attendanceId;

  SlotAttendance({
    required this.slot,
    required this.present,
    required this.attendanceId,
  });
}

/// Controller for viewing attendance history
class AttendanceHistoryController extends GetxController {
  final String courseId;
  final String courseName;

  AttendanceHistoryController({
    required this.courseId,
    required this.courseName,
  });

  final ApiClient _client = ApiClient();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final days = <DayAttendanceData>[].obs;

  // Date range (default to last 10 days for better UI)
  final Rx<DateTime> startDate = DateTime.now().subtract(const Duration(days: 10)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  // Selected day for detail view
  final Rx<DayAttendanceData?> selectedDay = Rx<DayAttendanceData?>(null);

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  /// Load attendance history for the date range
  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = '';
    days.clear();
    selectedDay.value = null;

    try {
      final startStr = _formatDate(startDate.value);
      final endStr = _formatDate(endDate.value);

      final response = await _client.getJson(
        Endpoints.getAttendanceHistory(courseId, startStr, endStr),
      );

      if (response['success'] == true) {
        final datesList = response['dates'] as List? ?? [];
        days.value = datesList
            .map((d) => DayAttendanceData.fromJson(d))
            .toList();

        // Auto-select the first day if available
        if (days.isNotEmpty) {
          selectedDay.value = days.first;
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load history';
      }
    } catch (e) {
      errorMessage.value = 'Error loading history: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a day to view details
  void selectDay(DayAttendanceData day) {
    selectedDay.value = day;
  }

  /// Update date range and reload
  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    loadHistory();
  }

  /// Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format date for display as DD/MM/YYYY
  String formatDateDisplay(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Format date with day name
  String formatDateWithDay(DateTime date) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[date.weekday - 1];
    return '$dayName, ${date.day}/${date.month}/${date.year}';
  }

  /// Get summary statistics
  Map<String, dynamic> get summary {
    if (days.isEmpty) {
      return {
        'totalDays': 0,
        'avgAttendance': 0.0,
        'totalPresent': 0,
        'totalAbsent': 0,
      };
    }

    int totalPresent = 0;
    int totalAbsent = 0;
    double totalPercentage = 0;

    for (final day in days) {
      totalPresent += day.presentCount;
      totalAbsent += day.absentCount;
      totalPercentage += day.attendancePercentage;
    }

    return {
      'totalDays': days.length,
      'avgAttendance': days.isNotEmpty ? totalPercentage / days.length : 0.0,
      'totalPresent': totalPresent,
      'totalAbsent': totalAbsent,
    };
  }
}

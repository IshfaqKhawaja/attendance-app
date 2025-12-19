import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/network/endpoints.dart';
import '../../core/network/api_client.dart';

/// Model for a single attendance record (one row in DB)
class AttendanceRecord {
  final int? attendanceId; // Unique ID for precise updates with multiple slots
  final String studentId;
  final String courseId;
  final DateTime date;
  bool present;

  AttendanceRecord({
    this.attendanceId,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.present,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'student_id': studentId,
      'course_id': courseId,
      'date': date.toIso8601String().split('T')[0],
      'present': present,
    };
    // Include attendance_id if available (for multi-slot updates)
    if (attendanceId != null) {
      map['attendance_id'] = attendanceId;
    }
    return map;
  }
}

/// Model for grouped student attendance (multiple records per student)
class StudentAttendanceGroup {
  final String studentId;
  final String studentName;
  final String courseId;
  final DateTime date;
  final List<AttendanceRecord> records; // All records for this student on this date
  int presentCount; // How many are marked present

  StudentAttendanceGroup({
    required this.studentId,
    required this.studentName,
    required this.courseId,
    required this.date,
    required this.records,
    required this.presentCount,
  });

  int get totalSlots => records.length;

  /// Update records based on new present count
  void setPresentCount(int count) {
    presentCount = count.clamp(0, totalSlots);
    // Mark first 'count' records as present, rest as absent
    for (int i = 0; i < records.length; i++) {
      records[i].present = i < presentCount;
    }
  }
}

/// Controller for HOD to edit attendance for today and previous day
class EditAttendanceController extends GetxController {
  final String courseId;
  final String courseName;

  EditAttendanceController({
    required this.courseId,
    required this.courseName,
  });

  final ApiClient client = ApiClient();

  // Loading states
  var isLoadingToday = false.obs;
  var isLoadingPrevious = false.obs;
  var isSaving = false.obs;

  // Grouped attendance data (by student)
  var todayAttendance = <StudentAttendanceGroup>[].obs;
  var previousDayAttendance = <StudentAttendanceGroup>[].obs;

  // Dates
  var todayDate = DateTime.now().obs;
  var previousDate = Rxn<DateTime>();

  // Error messages
  var todayError = ''.obs;
  var previousError = ''.obs;

  // Track if changes were made
  var hasChangesToday = false.obs;
  var hasChangesPrevious = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    await Future.wait([
      loadTodayAttendance(),
      loadPreviousDayAttendance(),
    ]);
  }

  /// Group raw attendance records by student
  List<StudentAttendanceGroup> _groupByStudent(List<dynamic> records, String courseId) {
    final Map<String, List<AttendanceRecord>> grouped = {};
    final Map<String, String> studentNames = {};

    for (final r in records) {
      final studentId = r['student_id'] ?? '';
      final record = AttendanceRecord(
        attendanceId: r['attendance_id'] as int?, // Parse attendance_id for updates
        studentId: studentId,
        courseId: r['course_id'] ?? courseId,
        date: DateTime.parse(r['date']),
        present: r['present'] ?? false,
      );

      if (!grouped.containsKey(studentId)) {
        grouped[studentId] = [];
        studentNames[studentId] = r['student_name'] ?? studentId;
      }
      grouped[studentId]!.add(record);
    }

    // Convert to list of groups
    return grouped.entries.map((entry) {
      final studentRecords = entry.value;
      final presentCount = studentRecords.where((r) => r.present).length;

      return StudentAttendanceGroup(
        studentId: entry.key,
        studentName: studentNames[entry.key] ?? entry.key,
        courseId: courseId,
        date: studentRecords.first.date,
        records: studentRecords,
        presentCount: presentCount,
      );
    }).toList()
      ..sort((a, b) => a.studentId.compareTo(b.studentId));
  }

  Future<void> loadTodayAttendance() async {
    isLoadingToday.value = true;
    todayError.value = '';
    todayAttendance.clear();

    try {
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final res = await client.getJson(Endpoints.getAttendanceForDate(courseId, dateStr));

      if (res['success'] == true) {
        final records = res['attendance_records'] as List? ?? [];
        if (records.isEmpty) {
          todayError.value = 'No attendance taken today';
        } else {
          todayAttendance.value = _groupByStudent(records, courseId);
        }
      } else {
        todayError.value = res['message'] ?? 'Failed to load attendance';
      }
    } catch (e) {
      todayError.value = 'No attendance taken today';
    } finally {
      isLoadingToday.value = false;
    }
  }

  Future<void> loadPreviousDayAttendance() async {
    isLoadingPrevious.value = true;
    previousError.value = '';
    previousDayAttendance.clear();

    try {
      // First get the last working day
      final lastDayRes = await client.getJson(Endpoints.getLastWorkingDay(courseId));

      if (lastDayRes['success'] != true || lastDayRes['last_working_day'] == null) {
        previousError.value = 'No previous attendance records';
        isLoadingPrevious.value = false;
        return;
      }

      final lastDay = lastDayRes['last_working_day'] as String;
      previousDate.value = DateTime.parse(lastDay);

      // Now get attendance for that day
      final res = await client.getJson(Endpoints.getAttendanceForDate(courseId, lastDay));

      if (res['success'] == true) {
        final records = res['attendance_records'] as List? ?? [];
        if (records.isEmpty) {
          previousError.value = 'No attendance records found';
        } else {
          previousDayAttendance.value = _groupByStudent(records, courseId);
        }
      } else {
        previousError.value = res['message'] ?? 'Failed to load attendance';
      }
    } catch (e) {
      previousError.value = 'No previous attendance records';
    } finally {
      isLoadingPrevious.value = false;
    }
  }

  /// Update present count for a student (used for dropdown selection)
  void updateTodayPresentCount(int index, int count) {
    if (index >= 0 && index < todayAttendance.length) {
      todayAttendance[index].setPresentCount(count);
      todayAttendance.refresh();
      hasChangesToday.value = true;
    }
  }

  void updatePreviousPresentCount(int index, int count) {
    if (index >= 0 && index < previousDayAttendance.length) {
      previousDayAttendance[index].setPresentCount(count);
      previousDayAttendance.refresh();
      hasChangesPrevious.value = true;
    }
  }

  /// Toggle for single-slot attendance (backwards compatible)
  void toggleTodayAttendance(int index) {
    if (index >= 0 && index < todayAttendance.length) {
      final group = todayAttendance[index];
      final newCount = group.presentCount > 0 ? 0 : group.totalSlots;
      group.setPresentCount(newCount);
      todayAttendance.refresh();
      hasChangesToday.value = true;
    }
  }

  void togglePreviousAttendance(int index) {
    if (index >= 0 && index < previousDayAttendance.length) {
      final group = previousDayAttendance[index];
      final newCount = group.presentCount > 0 ? 0 : group.totalSlots;
      group.setPresentCount(newCount);
      previousDayAttendance.refresh();
      hasChangesPrevious.value = true;
    }
  }

  /// Select all students as fully present
  void selectAllPresent({required bool isToday}) {
    final attendance = isToday ? todayAttendance : previousDayAttendance;
    for (final group in attendance) {
      group.setPresentCount(group.totalSlots);
    }
    attendance.refresh();
    if (isToday) {
      hasChangesToday.value = true;
    } else {
      hasChangesPrevious.value = true;
    }
  }

  /// Deselect all students (mark as absent)
  void deselectAll({required bool isToday}) {
    final attendance = isToday ? todayAttendance : previousDayAttendance;
    for (final group in attendance) {
      group.setPresentCount(0);
    }
    attendance.refresh();
    if (isToday) {
      hasChangesToday.value = true;
    } else {
      hasChangesPrevious.value = true;
    }
  }

  /// Check if all students are marked as fully present
  bool areAllPresent({required bool isToday}) {
    final attendance = isToday ? todayAttendance : previousDayAttendance;
    if (attendance.isEmpty) return false;
    for (final group in attendance) {
      if (group.presentCount < group.totalSlots) return false;
    }
    return true;
  }

  Future<bool> saveChanges({required bool isToday}) async {
    final attendance = isToday ? todayAttendance : previousDayAttendance;
    final hasChanges = isToday ? hasChangesToday.value : hasChangesPrevious.value;

    if (!hasChanges || attendance.isEmpty) {
      Get.snackbar(
        'No Changes',
        'No changes to save',
        colorText: Colors.orange,
        backgroundColor: Colors.orange.withValues(alpha: 0.1),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isSaving.value = true;

    try {
      // Flatten all records from all groups
      final allRecords = <Map<String, dynamic>>[];
      for (final group in attendance) {
        for (final record in group.records) {
          allRecords.add(record.toJson());
        }
      }

      final res = await client.putJson(Endpoints.updateAttendanceBulk, {
        'attendances': allRecords,
      });

      if (res['success'] == true) {
        Get.snackbar(
          'Success',
          res['message'] ?? 'Attendance updated successfully',
          colorText: Colors.green,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          snackPosition: SnackPosition.BOTTOM,
        );

        // Reset changes flag
        if (isToday) {
          hasChangesToday.value = false;
        } else {
          hasChangesPrevious.value = false;
        }

        return true;
      } else {
        Get.snackbar(
          'Error',
          res['message'] ?? 'Failed to update attendance',
          colorText: Colors.red,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update attendance: $e',
        colorText: Colors.red,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

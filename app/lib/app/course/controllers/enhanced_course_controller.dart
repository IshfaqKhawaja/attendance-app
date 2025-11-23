import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/core.dart';
import '../../models/student_model.dart';
import '../models/student_attendence.dart';

/// Enhanced Course Controller using new architecture patterns
/// 
/// Features:
/// - Service layer integration
/// - Enhanced error handling
/// - Better state management
/// - Improved user feedback
class EnhancedCourseController extends BaseController {
  
  // Dependencies
  final ApiClient _apiClient = ApiClient();
  late final ErrorHandlingService _errorService;
  late final NavigationService _navigationService;

  // Course data
  final String courseId;
  var students = <StudentModel>[].obs;
  
  // Loading states
  var isLoadingStudents = false.obs;
  var isLoadingAttendance = false.obs;
  
  // Attendance data
  var countedAs = 1.obs;
  var attendanceMarked = <StudentAttendanceList>[].obs;
  var selectedDate = DateTime.now().obs;
  
  // UI state
  var isGeneratingReport = false.obs;
  var isSubmittingAttendance = false.obs;

  EnhancedCourseController({required this.courseId});

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
    loadStudents();
  }

  void _initializeDependencies() {
    try {
      _errorService = Get.find<ErrorHandlingService>();
      _navigationService = Get.find<NavigationService>();
    } catch (e) {
      print('Warning: Some services not initialized: $e');
    }
  }

  /// Load students with enhanced error handling
  Future<void> loadStudents() async {
    try {
      isLoadingStudents.value = true;
      final response = await _apiClient.getJson(Endpoints.getStudentsByCourseId(courseId));
      
      if (response["success"] == true) {
        students.value = (response["students"] as List)
            .map((e) => StudentModel.fromJson(e))
            .toList();
        
        if (_navigationService != null) {
          _navigationService.showSuccessSnackbar('Students loaded successfully');
        }
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load students');
      }
    } catch (e) {
      if (_errorService != null) {
        _errorService.logError('Failed to load students: $e');
      }
      
      if (_navigationService != null) {
        _navigationService.showErrorSnackbar('Failed to load students: $e');
      } else {
        Get.snackbar('Error', 'Failed to load students: $e');
      }
    } finally {
      isLoadingStudents.value = false;
    }
  }

  /// Initialize attendance marking for current students
  Future<void> initializeAttendance() async {
    if (students.isEmpty) {
      await loadStudents();
    }

    attendanceMarked.value = students.map((student) {
      return StudentAttendanceList(
        studentId: student.studentId,
        studentName: student.studentName,
        courseId: courseId,
        date: selectedDate.value,
        marked: List.generate(countedAs.value, (_) => false),
      );
    }).toList();
  }

  /// Update attendance count and reinitialize attendance data
  void updateAttendanceCount(int count) {
    if (count < 1) return;
    
    countedAs.value = count;
    
    // Recreate attendance data with new count
    if (attendanceMarked.isNotEmpty) {
      attendanceMarked.value = attendanceMarked.map((attendance) {
        return StudentAttendanceList(
          studentId: attendance.studentId,
          studentName: attendance.studentName,
          courseId: attendance.courseId,
          date: attendance.date,
          marked: List.generate(count, (index) => 
            index < attendance.marked.length ? attendance.marked[index] : false),
        );
      }).toList();
    }
  }

  /// Toggle attendance for a student in a specific session
  void toggleAttendance(String studentId, int sessionIndex) {
    final attendanceIndex = attendanceMarked.indexWhere(
      (attendance) => attendance.studentId == studentId,
    );
    
    if (attendanceIndex != -1 && sessionIndex < countedAs.value) {
      attendanceMarked[attendanceIndex].marked[sessionIndex] = 
          !attendanceMarked[attendanceIndex].marked[sessionIndex];
      attendanceMarked.refresh();
    }
  }

  /// Mark all students as present/absent for all sessions
  void markAllStudents(bool present) {
    for (var attendance in attendanceMarked) {
      for (int i = 0; i < attendance.marked.length; i++) {
        attendance.marked[i] = present;
      }
    }
    attendanceMarked.refresh();
  }

  /// Prepare attendance data for API submission
  List<StudentAttendance> _prepareAttendanceData() {
    final attendanceList = <StudentAttendance>[];
    
    for (var attendance in attendanceMarked) {
      for (int sessionIndex = 0; sessionIndex < countedAs.value; sessionIndex++) {
        attendanceList.add(StudentAttendance(
          studentId: attendance.studentId,
          studentName: attendance.studentName,
          courseId: attendance.courseId,
          date: attendance.date,
          present: attendance.marked[sessionIndex],
        ));
      }
    }
    
    return attendanceList;
  }

  /// Submit attendance with enhanced error handling
  Future<void> submitAttendance() async {
    if (attendanceMarked.isEmpty) {
      Get.snackbar('Error', 'No attendance data to submit');
      return;
    }

    try {
      isSubmittingAttendance.value = true;
      
      final attendanceData = _prepareAttendanceData();
      final response = await _apiClient.postJson(
        Endpoints.addAttendanceBulk,
        {
          'attendances': attendanceData.map((e) => e.toJson()).toList(),
        },
      );

      if (response["success"] == true) {
        Get.snackbar("Success", response["message"] ?? 'Attendance submitted successfully', 
          colorText: Colors.green);
        clearAttendance();
      } else {
        throw Exception(response["message"] ?? 'Failed to submit attendance');
      }
    } catch (e) {
      _errorService.logError('Failed to submit attendance: $e');
      Get.snackbar("Error", "Failed to submit attendance: $e", colorText: Colors.red);
    } finally {
      isSubmittingAttendance.value = false;
    }
  }

  /// Show enhanced date range picker dialog
  Future<void> showReportDateRangePicker(BuildContext context, String courseName) async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (dateRange == null) return;

    final confirmed = await _showConfirmationDialog(
      context,
      'Generate Report',
      'Generate attendance report from ${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}?',
    );

    if (confirmed == true) {
      await generateReport(courseName, dateRange.start, dateRange.end);
    }
  }

  /// Generate attendance report with progress tracking
  Future<void> generateReport(String courseName, DateTime startDate, DateTime endDate) async {
    try {
      isGeneratingReport.value = true;
      
      final bytes = await _apiClient.postBytes(
        Endpoints.generateAttendanceReport,
        {
          'course_name': courseName,
          'course_id': courseId,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      // Save file to device
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'attendance_report_${courseId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      
      await file.writeAsBytes(bytes);
      
      // Open file
      await OpenFile.open(filePath);
      
      Get.snackbar("Success", "Report generated and saved", colorText: Colors.green);
    } catch (e) {
      _errorService.logError('Failed to generate report: $e');
      Get.snackbar("Error", "Failed to generate report: $e", colorText: Colors.red);
    } finally {
      isGeneratingReport.value = false;
    }
  }

  /// Show confirmation dialog
  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get attendance statistics
  Map<String, int> getAttendanceStats() {
    if (attendanceMarked.isEmpty) {
      return {
        'total': 0,
        'present': 0,
        'absent': 0,
        'percentage': 0,
      };
    }

    int totalSessions = countedAs.value * attendanceMarked.length;
    int presentCount = 0;

    for (var attendance in attendanceMarked) {
      presentCount += attendance.marked.where((present) => present).length;
    }

    int absentCount = totalSessions - presentCount;
    int percentage = totalSessions > 0 ? ((presentCount / totalSessions) * 100).round() : 0;

    return {
      'total': totalSessions,
      'present': presentCount,
      'absent': absentCount,
      'percentage': percentage,
    };
  }

  /// Clear all attendance data
  void clearAttendance() {
    attendanceMarked.clear();
    countedAs.value = 1;
    selectedDate.value = DateTime.now();
  }

  /// Clear all data and reset state
  void clearAllData() {
    clearAttendance();
    students.clear();
    isLoadingStudents.value = false;
    isLoadingAttendance.value = false;
    isGeneratingReport.value = false;
    isSubmittingAttendance.value = false;
  }

  /// Refresh data
  Future<void> refreshData() async {
    clearAllData();
    await loadStudents();
  }

  @override
  void onClose() {
    clearAllData();
    super.onClose();
  }
}
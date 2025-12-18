import 'package:get/get.dart';

import 'base_service.dart';
import '../utils/platform_utils.dart';

// Conditional imports for sqflite (not supported on web)
import 'local_database_service_mobile.dart'
    if (dart.library.html) 'local_database_service_web.dart' as db_impl;

/// Local database service for offline data storage
///
/// Features:
/// - SQLite database management (mobile only)
/// - In-memory storage for web
/// - Offline attendance caching
/// - Data synchronization
/// - Database migrations
/// - CRUD operations for local storage
class LocalDatabaseService extends BaseService {
  static LocalDatabaseService get to => Get.find();

  db_impl.LocalDatabaseImpl? _impl;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    // Prevent double initialization
    if (_initialized) {
      Get.log('LocalDatabaseService already initialized, skipping');
      return;
    }

    try {
      _impl = db_impl.LocalDatabaseImpl();
      await _impl!.initialize();
      _initialized = true;
      Get.log('LocalDatabaseService initialized (Platform: ${PlatformUtils.platformName})');
    } catch (e) {
      Get.log('Failed to initialize LocalDatabaseService: $e');
      // Don't rethrow on web - allow app to continue without local database
      if (!PlatformUtils.isWeb) {
        rethrow;
      }
    }
  }

  // Student operations
  Future<void> insertStudent(Map<String, dynamic> student) async {
    await _impl?.insertStudent(student);
  }

  Future<List<Map<String, dynamic>>> getStudents({String? courseId}) async {
    return await _impl?.getStudents(courseId: courseId) ?? [];
  }

  Future<Map<String, dynamic>?> getStudent(String studentId) async {
    return await _impl?.getStudent(studentId);
  }

  // Attendance operations
  Future<void> insertAttendance(Map<String, dynamic> attendance) async {
    await _impl?.insertAttendance(attendance);
  }

  Future<void> insertBulkAttendance(List<Map<String, dynamic>> attendanceList) async {
    await _impl?.insertBulkAttendance(attendanceList);
  }

  Future<List<Map<String, dynamic>>> getAttendance({
    String? studentId,
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _impl?.getAttendance(
      studentId: studentId,
      courseId: courseId,
      startDate: startDate,
      endDate: endDate,
    ) ?? [];
  }

  // Course operations
  Future<void> insertCourse(Map<String, dynamic> course) async {
    await _impl?.insertCourse(course);
  }

  Future<List<Map<String, dynamic>>> getCourses() async {
    return await _impl?.getCourses() ?? [];
  }

  // Synchronization operations
  Future<void> addToSyncQueue(String tableName, String recordId, String action, Map<String, dynamic> data) async {
    await _impl?.addToSyncQueue(tableName, recordId, action, data);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    return await _impl?.getPendingSyncItems() ?? [];
  }

  Future<void> markAsSynced(String tableName, String recordId) async {
    await _impl?.markAsSynced(tableName, recordId);
  }

  Future<void> removeSyncItem(int syncId) async {
    await _impl?.removeSyncItem(syncId);
  }

  // Utility operations
  Future<int> getUnsyncedCount(String tableName) async {
    return await _impl?.getUnsyncedCount(tableName) ?? 0;
  }

  Future<void> clearTable(String tableName) async {
    await _impl?.clearTable(tableName);
  }

  Future<void> clearAllData() async {
    await _impl?.clearAllData();
  }

  Future<Map<String, int>> getDatabaseStats() async {
    return await _impl?.getDatabaseStats() ?? {};
  }

  @override
  void onClose() {
    _impl?.dispose();
    Get.log('LocalDatabaseService disposed');
    super.onClose();
  }
}
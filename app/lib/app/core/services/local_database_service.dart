import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:get/get.dart';

import 'base_service.dart';

/// Local database service for offline data storage
/// 
/// Features:
/// - SQLite database management
/// - Offline attendance caching
/// - Data synchronization
/// - Database migrations
/// - CRUD operations for local storage
class LocalDatabaseService extends BaseService {
  static LocalDatabaseService get to => Get.find();
  
  Database? _database;
  static const String _databaseName = 'attendance_app.db';
  static const int _databaseVersion = 1;
  
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }
  
  @override
  Future<void> initialize() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, _databaseName);
      
      _database = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
      
      Get.log('LocalDatabaseService initialized: $path');
    } catch (e) {
      Get.log('Failed to initialize LocalDatabaseService: $e');
      rethrow;
    }
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    // Create students table
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        student_id TEXT UNIQUE NOT NULL,
        student_name TEXT NOT NULL,
        semester_id TEXT,
        course_ids TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    
    // Create attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        course_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        present INTEGER NOT NULL,
        session_number INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (student_id) REFERENCES students (student_id)
      )
    ''');
    
    // Create courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        course_name TEXT NOT NULL,
        course_code TEXT,
        semester_id TEXT,
        teacher_id TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
    
    // Create sync_queue table for pending synchronization
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_attendance_student_date ON attendance (student_id, date)');
    await db.execute('CREATE INDEX idx_attendance_course_date ON attendance (course_id, date)');
    await db.execute('CREATE INDEX idx_sync_queue_table ON sync_queue (table_name, action)');
    
    Get.log('Database tables created successfully');
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    Get.log('Database upgraded from $oldVersion to $newVersion');
  }
  
  // Student operations
  Future<void> insertStudent(Map<String, dynamic> student) async {
    student['created_at'] = DateTime.now().millisecondsSinceEpoch;
    student['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    student['synced'] = 0;
    
    await database.insert('students', student, 
      conflictAlgorithm: ConflictAlgorithm.replace);
    Get.log('Student inserted: ${student['student_id']}');
  }
  
  Future<List<Map<String, dynamic>>> getStudents({String? courseId}) async {
    if (courseId != null) {
      return await database.query(
        'students',
        where: 'course_ids LIKE ?',
        whereArgs: ['%$courseId%'],
      );
    }
    return await database.query('students');
  }
  
  Future<Map<String, dynamic>?> getStudent(String studentId) async {
    final result = await database.query(
      'students',
      where: 'student_id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
  
  // Attendance operations
  Future<void> insertAttendance(Map<String, dynamic> attendance) async {
    attendance['created_at'] = DateTime.now().millisecondsSinceEpoch;
    attendance['synced'] = 0;
    
    await database.insert('attendance', attendance,
      conflictAlgorithm: ConflictAlgorithm.replace);
    Get.log('Attendance inserted: ${attendance['student_id']} - ${attendance['date']}');
  }
  
  Future<void> insertBulkAttendance(List<Map<String, dynamic>> attendanceList) async {
    final batch = database.batch();
    
    for (final attendance in attendanceList) {
      attendance['created_at'] = DateTime.now().millisecondsSinceEpoch;
      attendance['synced'] = 0;
      batch.insert('attendance', attendance, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    
    await batch.commit(noResult: true);
    Get.log('Bulk attendance inserted: ${attendanceList.length} records');
  }
  
  Future<List<Map<String, dynamic>>> getAttendance({
    String? studentId,
    String? courseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String where = '1=1';
    List<dynamic> whereArgs = [];
    
    if (studentId != null) {
      where += ' AND student_id = ?';
      whereArgs.add(studentId);
    }
    
    if (courseId != null) {
      where += ' AND course_id = ?';
      whereArgs.add(courseId);
    }
    
    if (startDate != null) {
      where += ' AND date >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    
    if (endDate != null) {
      where += ' AND date <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    
    return await database.query(
      'attendance',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
  }
  
  // Course operations
  Future<void> insertCourse(Map<String, dynamic> course) async {
    course['created_at'] = DateTime.now().millisecondsSinceEpoch;
    course['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    course['synced'] = 0;
    
    await database.insert('courses', course,
      conflictAlgorithm: ConflictAlgorithm.replace);
    Get.log('Course inserted: ${course['course_name']}');
  }
  
  Future<List<Map<String, dynamic>>> getCourses() async {
    return await database.query('courses', orderBy: 'course_name ASC');
  }
  
  // Synchronization operations
  Future<void> addToSyncQueue(String tableName, String recordId, String action, Map<String, dynamic> data) async {
    await database.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data.toString(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }
  
  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    return await database.query(
      'sync_queue',
      orderBy: 'created_at ASC',
      limit: 50,
    );
  }
  
  Future<void> markAsSynced(String tableName, String recordId) async {
    await database.update(
      tableName,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }
  
  Future<void> removeSyncItem(int syncId) async {
    await database.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [syncId],
    );
  }
  
  // Utility operations
  Future<int> getUnsyncedCount(String tableName) async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName WHERE synced = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  Future<void> clearTable(String tableName) async {
    await database.delete(tableName);
    Get.log('Table $tableName cleared');
  }
  
  Future<void> clearAllData() async {
    await database.delete('students');
    await database.delete('attendance');
    await database.delete('courses');
    await database.delete('sync_queue');
    Get.log('All data cleared from local database');
  }
  
  Future<Map<String, int>> getDatabaseStats() async {
    final students = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM students')) ?? 0;
    final attendance = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM attendance')) ?? 0;
    final courses = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM courses')) ?? 0;
    final pendingSync = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM sync_queue')) ?? 0;
    
    return {
      'students': students,
      'attendance': attendance,
      'courses': courses,
      'pendingSync': pendingSync,
    };
  }
  
  @override
  void onClose() {
    _database?.close();
    Get.log('LocalDatabaseService disposed');
    super.onClose();
  }
}
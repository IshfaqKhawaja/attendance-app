import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;

import 'base_service.dart';

/// Local notification service for app notifications
/// 
/// Features:
/// - Local notifications
/// - Scheduled notifications
/// - Notification channels
/// - Custom notification actions
/// - Notification history
class NotificationService extends BaseService {
  static NotificationService get to => Get.find();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  final RxList<AppNotification> notificationHistory = <AppNotification>[].obs;
  
  @override
  Future<void> initialize() async {
    try {
      await _initializeNotifications();
      await _createNotificationChannels();
      Get.log('NotificationService initialized');
    } catch (e) {
      Get.log('Failed to initialize NotificationService: $e');
      rethrow;
    }
  }
  
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }
  
  Future<void> _createNotificationChannels() async {
    // Attendance reminders channel
    const attendanceChannel = AndroidNotificationChannel(
      'attendance_reminders',
      'Attendance Reminders',
      description: 'Notifications for attendance marking reminders',
      importance: Importance.high,
    );
    
    // General app notifications channel
    const generalChannel = AndroidNotificationChannel(
      'general_notifications',
      'General Notifications',
      description: 'General app notifications and updates',
      importance: Importance.defaultImportance,
    );
    
    // Data sync notifications channel
    const syncChannel = AndroidNotificationChannel(
      'sync_notifications',
      'Data Synchronization',
      description: 'Notifications about data sync status',
      importance: Importance.low,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(attendanceChannel);
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(syncChannel);
  }
  
  Future<bool> requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return false;
  }
  
  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(channel),
      _getChannelName(channel),
      channelDescription: _getChannelDescription(channel),
      importance: _mapPriorityToImportance(priority),
      priority: _mapPriorityToAndroidPriority(priority),
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    
    _addToHistory(AppNotification(
      id: id,
      title: title,
      body: body,
      channel: channel,
      timestamp: DateTime.now(),
    ));
    
    Get.log('Notification shown: $title');
  }
  
  /// Schedule notification for future delivery
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(channel),
      _getChannelName(channel),
      channelDescription: _getChannelDescription(channel),
      importance: _mapPriorityToImportance(priority),
      priority: _mapPriorityToAndroidPriority(priority),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    Get.log('Notification scheduled: $title for ${scheduledTime.toString()}');
  }
  
  /// Schedule daily attendance reminder
  Future<void> scheduleAttendanceReminder({
    required String courseName,
    required TimeOfDay reminderTime,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    await scheduleNotification(
      id: courseName.hashCode,
      title: 'Attendance Reminder',
      body: 'Don\'t forget to mark attendance for $courseName',
      scheduledTime: scheduledTime,
      channel: NotificationChannel.attendance,
      priority: NotificationPriority.high,
    );
  }
  
  /// Show attendance completion notification
  Future<void> showAttendanceCompletedNotification({
    required String courseName,
    required int studentsCount,
    required int presentCount,
  }) async {
    final percentage = (presentCount / studentsCount * 100).round();
    
    await showNotification(
      id: 'attendance_completed_${courseName.hashCode}'.hashCode,
      title: 'Attendance Marked Successfully',
      body: '$courseName: $presentCount/$studentsCount students present ($percentage%)',
      channel: NotificationChannel.attendance,
      priority: NotificationPriority.normal,
    );
  }
  
  /// Show data sync notification
  Future<void> showSyncNotification({
    required bool success,
    String? details,
  }) async {
    await showNotification(
      id: 'sync_notification'.hashCode,
      title: success ? 'Data Sync Completed' : 'Data Sync Failed',
      body: details ?? (success ? 'All data has been synchronized' : 'Failed to sync data. Will retry later.'),
      channel: NotificationChannel.sync,
      priority: success ? NotificationPriority.low : NotificationPriority.normal,
    );
  }
  
  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    Get.log('Notification cancelled: $id');
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    Get.log('All notifications cancelled');
  }
  
  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
  
  void _onNotificationResponse(NotificationResponse response) {
    Get.log('Notification tapped: ${response.payload}');
    
    // Handle notification tap based on payload
    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }
  
  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate to appropriate screen
    // This would be customized based on your app's navigation structure
    Get.log('Handling notification payload: $payload');
  }
  
  void _addToHistory(AppNotification notification) {
    notificationHistory.insert(0, notification);
    
    // Keep only last 50 notifications
    if (notificationHistory.length > 50) {
      notificationHistory.removeLast();
    }
  }
  
  String _getChannelId(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.attendance:
        return 'attendance_reminders';
      case NotificationChannel.sync:
        return 'sync_notifications';
      case NotificationChannel.general:
        return 'general_notifications';
    }
  }
  
  String _getChannelName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.attendance:
        return 'Attendance Reminders';
      case NotificationChannel.sync:
        return 'Data Synchronization';
      case NotificationChannel.general:
        return 'General Notifications';
    }
  }
  
  String _getChannelDescription(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.attendance:
        return 'Notifications for attendance marking reminders';
      case NotificationChannel.sync:
        return 'Notifications about data sync status';
      case NotificationChannel.general:
        return 'General app notifications and updates';
    }
  }
  
  Importance _mapPriorityToImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
    }
  }
  
  Priority _mapPriorityToAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
    }
  }
}

/// Notification channel types
enum NotificationChannel { attendance, sync, general }

/// Notification priority levels
enum NotificationPriority { low, normal, high }

/// App notification model for history tracking
class AppNotification {
  final int id;
  final String title;
  final String body;
  final NotificationChannel channel;
  final DateTime timestamp;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    required this.timestamp,
  });
}
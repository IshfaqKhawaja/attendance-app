import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'base_service.dart';
import '../utils/platform_utils.dart';

// Conditional imports for flutter_local_notifications (not fully supported on web)
import 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart' as notif_impl;

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

/// Local notification service for app notifications
///
/// Features:
/// - Local notifications (mobile)
/// - Scheduled notifications (mobile)
/// - Notification channels (mobile)
/// - Custom notification actions (mobile)
/// - Notification history
/// - Web gracefully degrades (notifications disabled)
class NotificationService extends BaseService {
  static NotificationService get to => Get.find();

  notif_impl.NotificationServiceImpl? _impl;
  bool _initialized = false;
  final RxList<AppNotification> notificationHistory = <AppNotification>[].obs;

  @override
  Future<void> initialize() async {
    // Prevent double initialization
    if (_initialized) {
      Get.log('NotificationService already initialized, skipping');
      return;
    }

    try {
      _impl = notif_impl.NotificationServiceImpl();
      await _impl!.initialize();
      _initialized = true;
      Get.log('NotificationService initialized (Platform: ${PlatformUtils.platformName})');
    } catch (e) {
      Get.log('Failed to initialize NotificationService: $e');
      // Don't rethrow - allow app to continue without notifications
    }
  }

  Future<bool> requestPermissions() async {
    return await _impl?.requestPermissions() ?? false;
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
    await _impl?.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channel: channel,
      priority: priority,
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
    await _impl?.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      payload: payload,
      channel: channel,
      priority: priority,
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
    await _impl?.cancelNotification(id);
    Get.log('Notification cancelled: $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _impl?.cancelAllNotifications();
    Get.log('All notifications cancelled');
  }

  void _addToHistory(AppNotification notification) {
    notificationHistory.insert(0, notification);

    // Keep only last 50 notifications
    if (notificationHistory.length > 50) {
      notificationHistory.removeLast();
    }
  }
}

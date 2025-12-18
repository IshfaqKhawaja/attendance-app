import 'package:get/get.dart';

import 'notification_service.dart';

/// Web implementation of notification service
/// Web browsers have limited notification support, so this gracefully degrades
class NotificationServiceImpl {
  Future<void> initialize() async {
    Get.log('Web NotificationService initialized (limited functionality)');
    Get.log('Note: Local notifications are not fully supported on web');
  }

  Future<bool> requestPermissions() async {
    // Web notifications would require browser Notification API
    // For now, we gracefully degrade
    Get.log('Notification permissions not available on web');
    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    // On web, we could use browser Notification API in the future
    // For now, just log the notification
    Get.log('Web notification (not shown): $title - $body');
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    // Scheduled notifications not supported on web
    Get.log('Scheduled notification not supported on web: $title');
  }

  Future<void> cancelNotification(int id) async {
    // No-op on web
  }

  Future<void> cancelAllNotifications() async {
    // No-op on web
  }
}

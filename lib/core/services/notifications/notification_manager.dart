import 'notification_service.dart';
import 'local_notification_service.dart';
import 'notification_models.dart';

/// Notification manager - facade for notification operations
/// Allows easy switching between notification providers
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  // Default to local notifications
  // Replace with FirebaseNotificationService() or OneSignalNotificationService()
  NotificationService _service = LocalNotificationService();

  /// Set a custom notification service
  /// Example: NotificationManager().setService(FirebaseNotificationService())
  void setService(NotificationService service) {
    _service = service;
  }

  /// Get the current notification service
  NotificationService get service => _service;

  // Delegate all methods to the current service

  Future<void> initialize() => _service.initialize();

  Future<bool> requestPermissions() => _service.requestPermissions();

  Future<bool> areNotificationsEnabled() => _service.areNotificationsEnabled();

  Future<void> showNotification(NotificationPayload payload) =>
      _service.showNotification(payload);

  Future<void> scheduleNotification(
    NotificationPayload payload,
    DateTime scheduledDate,
  ) => _service.scheduleNotification(payload, scheduledDate);

  Future<void> cancelNotification(int id) => _service.cancelNotification(id);

  Future<void> cancelAllNotifications() => _service.cancelAllNotifications();

  Future<String?> getDeviceToken() => _service.getDeviceToken();

  Future<void> subscribeToTopic(String topic) =>
      _service.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _service.unsubscribeFromTopic(topic);

  Stream<NotificationResponse> get onNotificationTap =>
      _service.onNotificationTap;

  Stream<NotificationPayload> get onNotificationReceived =>
      _service.onNotificationReceived;
}

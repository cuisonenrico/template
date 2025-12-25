import 'dart:async';
import 'notification_models.dart';

/// Abstract notification service interface
/// Implement this interface for different notification providers:
/// - FirebaseNotificationService
/// - OneSignalNotificationService
/// - LocalNotificationService (default)
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request notification permissions from the user
  Future<bool> requestPermissions();

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled();

  /// Show a local notification
  Future<void> showNotification(NotificationPayload payload);

  /// Schedule a notification for later
  Future<void> scheduleNotification(
    NotificationPayload payload,
    DateTime scheduledDate,
  );

  /// Cancel a specific notification
  Future<void> cancelNotification(int id);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Get the device token for push notifications
  /// Returns null for local-only implementations
  Future<String?> getDeviceToken();

  /// Subscribe to a topic (for push notifications)
  /// No-op for local-only implementations
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  /// No-op for local-only implementations
  Future<void> unsubscribeFromTopic(String topic);

  /// Stream of notification taps (when user taps a notification)
  Stream<NotificationResponse> get onNotificationTap;

  /// Stream of incoming notifications (when app is in foreground)
  Stream<NotificationPayload> get onNotificationReceived;

  /// Handle background notification tap
  /// Override this to handle notification taps when app is closed
  Future<void> onBackgroundNotificationTap(NotificationResponse response);
}

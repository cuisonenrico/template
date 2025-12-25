import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as flutter_local_notifications;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'notification_service.dart';
import 'notification_models.dart';

/// Local notification service implementation
/// Handles local notifications without requiring external services
/// Can be extended to work with Firebase, OneSignal, etc.
class LocalNotificationService implements NotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final flutter_local_notifications.FlutterLocalNotificationsPlugin
  _notifications =
      flutter_local_notifications.FlutterLocalNotificationsPlugin();

  final StreamController<NotificationResponse> _notificationTapController =
      StreamController<NotificationResponse>.broadcast();

  final StreamController<NotificationPayload> _notificationReceivedController =
      StreamController<NotificationPayload>.broadcast();

  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    // Android initialization settings
    const androidSettings =
        flutter_local_notifications.AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );

    // iOS initialization settings
    const iosSettings =
        flutter_local_notifications.DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const initSettings = flutter_local_notifications.InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationTapped,
    );

    // Create default notification channels for Android
    if (Platform.isAndroid) {
      await _createDefaultChannels();
    }

    _initialized = true;
  }

  Future<void> _createDefaultChannels() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          flutter_local_notifications.AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // High priority channel
    await androidPlugin.createNotificationChannel(
      const flutter_local_notifications.AndroidNotificationChannel(
        'high_priority',
        'High Priority Notifications',
        description: 'This channel is used for important notifications.',
        importance: flutter_local_notifications.Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );

    // Default channel
    await androidPlugin.createNotificationChannel(
      const flutter_local_notifications.AndroidNotificationChannel(
        'default',
        'Default Notifications',
        description: 'This channel is used for general notifications.',
        importance: flutter_local_notifications.Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      ),
    );
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ requires notification permission
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            flutter_local_notifications.IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin == null) return false;

      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      return granted ?? false;
    }

    return true;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<
            flutter_local_notifications.IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin == null) return false;

      final settings = await iosPlugin.getNotificationAppLaunchDetails();
      return settings?.didNotificationLaunchApp ?? false;
    }

    return true;
  }

  @override
  Future<void> showNotification(NotificationPayload payload) async {
    if (!_initialized) await initialize();

    final androidDetails =
        flutter_local_notifications.AndroidNotificationDetails(
          payload.channelId ?? 'default',
          payload.channelName ?? 'Default Notifications',
          importance: _mapPriority(payload.priority),
          priority: _mapPriorityAndroid(payload.priority),
          styleInformation: payload.imageUrl != null
              ? flutter_local_notifications.BigPictureStyleInformation(
                  flutter_local_notifications.FilePathAndroidBitmap(
                    payload.imageUrl!,
                  ),
                )
              : null,
        );

    const iosDetails = flutter_local_notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = flutter_local_notifications.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      payload.id,
      payload.title,
      payload.body,
      details,
      payload: _encodePayload(payload.data),
    );
  }

  @override
  Future<void> scheduleNotification(
    NotificationPayload payload,
    DateTime scheduledDate,
  ) async {
    if (!_initialized) await initialize();

    final androidDetails =
        flutter_local_notifications.AndroidNotificationDetails(
          payload.channelId ?? 'default',
          payload.channelName ?? 'Default Notifications',
          importance: _mapPriority(payload.priority),
          priority: _mapPriorityAndroid(payload.priority),
        );

    const iosDetails = flutter_local_notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = flutter_local_notifications.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      payload.id,
      payload.title,
      payload.body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode:
          flutter_local_notifications.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: flutter_local_notifications
          .UILocalNotificationDateInterpretation
          .absoluteTime,
      payload: _encodePayload(payload.data),
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  @override
  Future<String?> getDeviceToken() async {
    // Local notifications don't have device tokens
    // Override this in Firebase/OneSignal implementations
    return null;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    // No-op for local notifications
    // Override this in Firebase/OneSignal implementations
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // No-op for local notifications
    // Override this in Firebase/OneSignal implementations
  }

  @override
  Stream<NotificationResponse> get onNotificationTap =>
      _notificationTapController.stream;

  @override
  Stream<NotificationPayload> get onNotificationReceived =>
      _notificationReceivedController.stream;

  @override
  Future<void> onBackgroundNotificationTap(
    NotificationResponse response,
  ) async {
    // Override this to handle background notification taps
    // e.g., navigate to specific screen, dispatch Redux action, etc.
  }

  // Helper methods

  void _onNotificationTapped(
    flutter_local_notifications.NotificationResponse response,
  ) {
    final payload = _decodePayload(response.payload ?? '');
    final notificationResponse = NotificationResponse(
      id: response.id ?? 0,
      actionId: response.actionId,
      input: response.input,
      payload: payload,
    );
    _notificationTapController.add(notificationResponse);
  }

  static void _onBackgroundNotificationTapped(
    flutter_local_notifications.NotificationResponse response,
  ) {
    // Static method for background handling
    // You can dispatch Redux actions or navigate here
  }

  flutter_local_notifications.Importance _mapPriority(
    NotificationPriority priority,
  ) {
    switch (priority) {
      case NotificationPriority.min:
        return flutter_local_notifications.Importance.min;
      case NotificationPriority.low:
        return flutter_local_notifications.Importance.low;
      case NotificationPriority.defaultPriority:
        return flutter_local_notifications.Importance.defaultImportance;
      case NotificationPriority.high:
        return flutter_local_notifications.Importance.high;
      case NotificationPriority.max:
        return flutter_local_notifications.Importance.max;
    }
  }

  flutter_local_notifications.Priority _mapPriorityAndroid(
    NotificationPriority priority,
  ) {
    switch (priority) {
      case NotificationPriority.min:
        return flutter_local_notifications.Priority.min;
      case NotificationPriority.low:
        return flutter_local_notifications.Priority.low;
      case NotificationPriority.defaultPriority:
        return flutter_local_notifications.Priority.defaultPriority;
      case NotificationPriority.high:
        return flutter_local_notifications.Priority.high;
      case NotificationPriority.max:
        return flutter_local_notifications.Priority.max;
    }
  }

  String _encodePayload(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}:${e.value}').join('|');
  }

  Map<String, dynamic> _decodePayload(String payload) {
    if (payload.isEmpty) return {};
    return Map.fromEntries(
      payload.split('|').map((e) {
        final parts = e.split(':');
        return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
      }),
    );
  }
}

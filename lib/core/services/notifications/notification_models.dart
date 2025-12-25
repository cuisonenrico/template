import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

/// Notification payload
@freezed
class NotificationPayload with _$NotificationPayload {
  const factory NotificationPayload({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    String? channelId,
    String? channelName,
    @Default({}) Map<String, dynamic> data,
    @Default(NotificationPriority.high) NotificationPriority priority,
    @Default(true) bool showBadge,
  }) = _NotificationPayload;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);
}

/// Notification response (when user taps on notification)
@freezed
class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required int id,
    String? actionId,
    String? input,
    @Default({}) Map<String, dynamic> payload,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}

/// Notification priority levels
enum NotificationPriority { min, low, defaultPriority, high, max }

/// Notification channel (Android)
@freezed
class NotificationChannel with _$NotificationChannel {
  const factory NotificationChannel({
    required String id,
    required String name,
    required String description,
    @Default(NotificationPriority.high) NotificationPriority importance,
    @Default(true) bool playSound,
    @Default(true) bool enableVibration,
    @Default(true) bool showBadge,
  }) = _NotificationChannel;

  factory NotificationChannel.fromJson(Map<String, dynamic> json) =>
      _$NotificationChannelFromJson(json);
}

/// Notification permission status
enum NotificationPermissionStatus {
  granted,
  denied,
  provisional,
  notDetermined,
}

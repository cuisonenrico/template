import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/services/notifications/notification_models.dart';

part 'notification_state.freezed.dart';
part 'notification_state.g.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(false) bool permissionsGranted,
    @Default(false) bool isInitialized,
    @Default([]) List<NotificationPayload> pendingNotifications,
    String? deviceToken,
    @Default([]) List<String> subscribedTopics,
    String? error,
  }) = _NotificationState;

  factory NotificationState.fromJson(Map<String, dynamic> json) =>
      _$NotificationStateFromJson(json);

  factory NotificationState.initialState() => const NotificationState();
}

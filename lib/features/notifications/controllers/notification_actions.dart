import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../../../core/services/notifications/notification_manager.dart';
import '../../../core/services/notifications/notification_models.dart';

// Initialize Notifications Action
class InitializeNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().initialize();

      return state.copyWith(
        notifications: state.notifications.copyWith(
          isInitialized: true,
          error: null,
        ),
      );
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Request Notification Permissions Action
class RequestNotificationPermissionsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      final granted = await NotificationManager().requestPermissions();

      if (granted) {
        // Get device token if available
        final token = await NotificationManager().getDeviceToken();

        return state.copyWith(
          notifications: state.notifications.copyWith(
            permissionsGranted: true,
            deviceToken: token,
            error: null,
          ),
        );
      } else {
        return state.copyWith(
          notifications: state.notifications.copyWith(
            permissionsGranted: false,
            error: 'Notification permissions denied',
          ),
        );
      }
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Show Notification Action
class ShowNotificationAction extends ReduxAction<AppState> {
  final NotificationPayload payload;

  ShowNotificationAction(this.payload);

  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().showNotification(payload);
      return null;
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Schedule Notification Action
class ScheduleNotificationAction extends ReduxAction<AppState> {
  final NotificationPayload payload;
  final DateTime scheduledDate;

  ScheduleNotificationAction(this.payload, this.scheduledDate);

  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().scheduleNotification(payload, scheduledDate);

      final updatedPending = [
        ...state.notifications.pendingNotifications,
        payload,
      ];

      return state.copyWith(
        notifications: state.notifications.copyWith(
          pendingNotifications: updatedPending,
          error: null,
        ),
      );
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Cancel Notification Action
class CancelNotificationAction extends ReduxAction<AppState> {
  final int notificationId;

  CancelNotificationAction(this.notificationId);

  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().cancelNotification(notificationId);

      final updatedPending = state.notifications.pendingNotifications
          .where((n) => n.id != notificationId)
          .toList();

      return state.copyWith(
        notifications: state.notifications.copyWith(
          pendingNotifications: updatedPending,
          error: null,
        ),
      );
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Cancel All Notifications Action
class CancelAllNotificationsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().cancelAllNotifications();

      return state.copyWith(
        notifications: state.notifications.copyWith(
          pendingNotifications: [],
          error: null,
        ),
      );
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Subscribe to Topic Action (for push notifications)
class SubscribeToTopicAction extends ReduxAction<AppState> {
  final String topic;

  SubscribeToTopicAction(this.topic);

  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().subscribeToTopic(topic);

      final updatedTopics = [...state.notifications.subscribedTopics, topic];

      return state.copyWith(
        notifications: state.notifications.copyWith(
          subscribedTopics: updatedTopics,
          error: null,
        ),
      );
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Unsubscribe from Topic Action
class UnsubscribeFromTopicAction extends ReduxAction<AppState> {
  final String topic;

  UnsubscribeFromTopicAction(this.topic);

  @override
  Future<AppState?> reduce() async {
    try {
      await NotificationManager().unsubscribeFromTopic(topic);

      final updatedTopics = state.notifications.subscribedTopics
          .where((t) => t != topic)
          .toList();

      return state.copyWith(
        notifications: state.notifications.copyWith(
          subscribedTopics: updatedTopics,
          error: null,
        ),
      );
    } catch (e) {
      return state.copyWith(
        notifications: state.notifications.copyWith(error: e.toString()),
      );
    }
  }
}

// Update Device Token Action
class UpdateDeviceTokenAction extends ReduxAction<AppState> {
  final String token;

  UpdateDeviceTokenAction(this.token);

  @override
  AppState? reduce() {
    return state.copyWith(
      notifications: state.notifications.copyWith(deviceToken: token),
    );
  }
}

// Clear Notification Error Action
class ClearNotificationErrorAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(
      notifications: state.notifications.copyWith(error: null),
    );
  }
}

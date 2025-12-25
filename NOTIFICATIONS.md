# Notification System Documentation

## Overview

This template includes a **robust, flexible notification system** that supports both local notifications and push notifications. The architecture is designed to work with any push notification service (Firebase, OneSignal, etc.) through a simple adapter pattern.

## Features

✅ **Local Notifications** - Works out of the box without external services  
✅ **Push Notification Ready** - Easy integration with Firebase, OneSignal, etc.  
✅ **Permission Handling** - iOS and Android permissions handled automatically  
✅ **Scheduled Notifications** - Schedule notifications for later  
✅ **Notification Channels** - Android notification channels pre-configured  
✅ **Redux Integration** - State management for notifications  
✅ **Type-Safe** - Full type safety with Freezed models  
✅ **Background Support** - Handle notifications when app is closed  

## Quick Start

### 1. Request Permissions

The notification system is initialized automatically in `main_common.dart`. To request permissions:

```dart
// Request permissions
dispatch(RequestNotificationPermissionsAction());
```

### 2. Show a Notification

```dart
final notification = NotificationPayload(
  id: 1,
  title: 'Hello!',
  body: 'This is a test notification',
  priority: NotificationPriority.high,
);

dispatch(ShowNotificationAction(notification));
```

### 3. Schedule a Notification

```dart
final notification = NotificationPayload(
  id: 2,
  title: 'Reminder',
  body: 'Don\'t forget to check your tasks!',
);

final scheduledDate = DateTime.now().add(Duration(hours: 1));

dispatch(ScheduleNotificationAction(notification, scheduledDate));
```

## Architecture

### Service Layer

```
NotificationManager (Facade)
    ↓
NotificationService (Interface)
    ↓
├── LocalNotificationService (Default)
├── FirebaseNotificationService (Optional)
└── OneSignalNotificationService (Custom)
```

### Key Files

- **[lib/core/services/notifications/notification_service.dart](lib/core/services/notifications/notification_service.dart)** - Interface
- **[lib/core/services/notifications/local_notification_service.dart](lib/core/services/notifications/local_notification_service.dart)** - Default implementation
- **[lib/core/services/notifications/notification_manager.dart](lib/core/services/notifications/notification_manager.dart)** - Facade
- **[lib/core/services/notifications/notification_models.dart](lib/core/services/notifications/notification_models.dart)** - Data models
- **[lib/features/notifications/controllers/notification_actions.dart](lib/features/notifications/controllers/notification_actions.dart)** - Redux actions

## Using Local Notifications (Default)

Local notifications work immediately without any external service. The `LocalNotificationService` is used by default.

### Show Notification

```dart
import 'package:template/core/services/notifications/notification_manager.dart';
import 'package:template/core/services/notifications/notification_models.dart';

final notification = NotificationPayload(
  id: 1,
  title: 'Welcome!',
  body: 'Thanks for using our app',
  channelId: 'high_priority',
  channelName: 'High Priority Notifications',
  priority: NotificationPriority.high,
  showBadge: true,
  data: {'screen': 'home', 'userId': '123'},
);

await NotificationManager().showNotification(notification);
```

### Schedule Notification

```dart
final notification = NotificationPayload(
  id: 2,
  title: 'Daily Reminder',
  body: 'Time to complete your daily tasks!',
);

final tomorrow = DateTime.now().add(Duration(days: 1));

await NotificationManager().scheduleNotification(notification, tomorrow);
```

### Cancel Notifications

```dart
// Cancel specific notification
await NotificationManager().cancelNotification(1);

// Cancel all notifications
await NotificationManager().cancelAllNotifications();
```

### Listen to Notification Taps

```dart
NotificationManager().onNotificationTap.listen((response) {
  print('Notification tapped: ${response.id}');
  print('Payload: ${response.payload}');
  
  // Navigate to specific screen based on payload
  if (response.payload['screen'] == 'home') {
    context.goToHome();
  }
});
```

## Using Redux Actions

All notification operations can be dispatched as Redux actions:

```dart
// Initialize (called automatically in main_common.dart)
dispatch(InitializeNotificationsAction());

// Request permissions
dispatch(RequestNotificationPermissionsAction());

// Show notification
dispatch(ShowNotificationAction(notification));

// Schedule notification
dispatch(ScheduleNotificationAction(notification, scheduledDate));

// Cancel notification
dispatch(CancelNotificationAction(1));

// Cancel all
dispatch(CancelAllNotificationsAction());

// Subscribe to topic (for push notifications)
dispatch(SubscribeToTopicAction('news'));

// Unsubscribe from topic
dispatch(UnsubscribeFromTopicAction('news'));
```

## Notification State

Access notification state in your UI:

```dart
StoreConnector<AppState, NotificationState>(
  converter: (store) => store.state.notifications,
  builder: (context, notificationState) {
    return Column(
      children: [
        Text('Permissions: ${notificationState.permissionsGranted}'),
        Text('Device Token: ${notificationState.deviceToken ?? 'N/A'}'),
        Text('Subscribed Topics: ${notificationState.subscribedTopics}'),
        if (notificationState.error != null)
          Text('Error: ${notificationState.error}'),
      ],
    );
  },
);
```

## Platform Permissions

### Android

Permissions are configured in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### iOS

Permissions are requested at runtime. Background modes configured in [ios/Runner/Info.plist](ios/Runner/Info.plist):

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

## Notification Channels (Android)

Pre-configured channels:

1. **high_priority** - Important notifications with sound and vibration
2. **default** - Regular notifications

Create custom channels:

```dart
final channel = NotificationChannel(
  id: 'promotions',
  name: 'Promotions',
  description: 'Special offers and deals',
  importance: NotificationPriority.low,
  playSound: false,
  enableVibration: false,
);
```

## Switching to Firebase Cloud Messaging

### Step 1: Add Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_messaging: ^15.1.5
```

### Step 2: Set Up Firebase

1. Follow [Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
2. Add `google-services.json` (Android) to `android/app/`
3. Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`
4. Run `flutterfire configure`

### Step 3: Update main_common.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/notifications/firebase_notification_service.dart';

void mainCommon(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set Firebase as notification service
  NotificationManager().setService(FirebaseNotificationService());
  
  // ... rest of initialization
}
```

### Step 4: Implement FirebaseNotificationService

Uncomment and implement methods in [lib/core/services/notifications/firebase_notification_service.dart](lib/core/services/notifications/firebase_notification_service.dart).

### Step 5: Configure iOS

In Xcode:
1. Enable Push Notifications capability
2. Enable Background Modes → Remote notifications
3. Upload APNs certificate to Firebase Console

### Step 6: Test Push Notifications

Send test notification from Firebase Console:
1. Go to Cloud Messaging
2. Click "Send your first message"
3. Enter notification details
4. Select target app
5. Send!

## Switching to OneSignal

### Step 1: Add Dependencies

```yaml
dependencies:
  onesignal_flutter: ^5.0.0
```

### Step 2: Create OneSignalNotificationService

```dart
class OneSignalNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    await OneSignal.initialize('YOUR_ONESIGNAL_APP_ID');
    await OneSignal.Notifications.requestPermission(true);
  }
  
  // Implement other methods...
}
```

### Step 3: Set Service in main_common.dart

```dart
NotificationManager().setService(OneSignalNotificationService());
```

## Custom Notification Service

Create your own service for any notification provider:

```dart
class CustomNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // Your initialization logic
  }

  @override
  Future<bool> requestPermissions() async {
    // Your permission logic
    return true;
  }

  @override
  Future<void> showNotification(NotificationPayload payload) async {
    // Your show notification logic
  }

  // Implement remaining methods...
}

// Use it
NotificationManager().setService(CustomNotificationService());
```

## Notification Models

### NotificationPayload

```dart
final notification = NotificationPayload(
  id: 1,                              // Unique ID
  title: 'Title',                     // Notification title
  body: 'Message body',               // Notification body
  imageUrl: 'https://...',            // Optional image
  channelId: 'high_priority',         // Android channel
  channelName: 'High Priority',       // Channel name
  data: {'key': 'value'},             // Custom data
  priority: NotificationPriority.high, // Priority level
  showBadge: true,                    // Show app badge
);
```

### NotificationResponse

When user taps notification:

```dart
NotificationManager().onNotificationTap.listen((response) {
  print('ID: ${response.id}');
  print('Action: ${response.actionId}');
  print('Input: ${response.input}');
  print('Data: ${response.payload}');
});
```

### NotificationPriority

```dart
enum NotificationPriority {
  min,              // Minimal priority
  low,              // Low priority
  defaultPriority,  // Default
  high,             // High priority (with sound)
  max,              // Maximum priority (heads-up)
}
```

## Best Practices

### 1. Request Permissions at Appropriate Time

Don't request permissions immediately on app start. Request when user needs the feature:

```dart
// ❌ Bad - Request on app start
void initState() {
  dispatch(RequestNotificationPermissionsAction());
}

// ✅ Good - Request when user enables feature
void onEnableNotifications() {
  dispatch(RequestNotificationPermissionsAction());
}
```

### 2. Use Unique IDs

Ensure each notification has a unique ID:

```dart
// ✅ Good - Use timestamp or UUID
final id = DateTime.now().millisecondsSinceEpoch;

// ✅ Good - Use sequential IDs
int _notificationIdCounter = 0;
final id = _notificationIdCounter++;
```

### 3. Handle Permission Denial

```dart
final granted = await NotificationManager().requestPermissions();
if (!granted) {
  // Show explanation or alternative
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Permissions Required'),
      content: Text('Enable notifications to receive updates'),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Settings'),
        ),
      ],
    ),
  );
}
```

### 4. Clean Up Scheduled Notifications

```dart
// Cancel old notifications on logout
dispatch(CancelAllNotificationsAction());

// Cancel specific notification when task is completed
dispatch(CancelNotificationAction(taskNotificationId));
```

### 5. Test on Real Devices

Notifications don't work on iOS Simulator. Always test on real devices.

## Troubleshooting

### Issue: Notifications not showing on Android

**Solution**: Check permissions in Settings and ensure channel is created:

```dart
// Verify permissions
final enabled = await NotificationManager().areNotificationsEnabled();
print('Notifications enabled: $enabled');
```

### Issue: Notifications not showing on iOS

**Solution**: 
1. Request permissions explicitly
2. Test on real device (not simulator)
3. Check Settings → Notifications → Your App

### Issue: Scheduled notifications not firing

**Solution**: Ensure exact alarm permission for Android 12+:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Issue: Background notification tap not working

**Solution**: Implement `onBackgroundNotificationTap` in your service:

```dart
@override
Future<void> onBackgroundNotificationTap(NotificationResponse response) async {
  // Dispatch navigation action or Redux action
  final payload = response.payload;
  if (payload['screen'] == 'orders') {
    // Navigate to orders screen
  }
}
```

## Example: Complete Notification Flow

```dart
class NotificationExample extends StatefulWidget {
  @override
  _NotificationExampleState createState() => _NotificationExampleState();
}

class _NotificationExampleState extends State<NotificationExample> {
  @override
  void initState() {
    super.initState();
    
    // Listen to notification taps
    NotificationManager().onNotificationTap.listen((response) {
      _handleNotificationTap(response);
    });
  }

  Future<void> _requestPermissions() async {
    final granted = await NotificationManager().requestPermissions();
    if (!granted) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _showNotification() async {
    final notification = NotificationPayload(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'New Message',
      body: 'You have a new message from John',
      data: {'type': 'message', 'senderId': '123'},
      priority: NotificationPriority.high,
    );

    await NotificationManager().showNotification(notification);
  }

  Future<void> _scheduleNotification() async {
    final notification = NotificationPayload(
      id: DateTime.now().millisecondsSinceEpoch + 1,
      title: 'Reminder',
      body: 'Meeting in 15 minutes',
      priority: NotificationPriority.high,
    );

    final scheduledTime = DateTime.now().add(Duration(minutes: 15));
    await NotificationManager().scheduleNotification(
      notification,
      scheduledTime,
    );
  }

  void _handleNotificationTap(NotificationResponse response) {
    final type = response.payload['type'];
    if (type == 'message') {
      final senderId = response.payload['senderId'];
      // Navigate to message screen
      context.go('/messages/$senderId');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Permissions Required'),
        content: Text('Please enable notifications in Settings'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Open app settings
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _requestPermissions,
              child: Text('Request Permissions'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showNotification,
              child: Text('Show Notification'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: Text('Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Next Steps

1. ✅ Notification system is ready to use
2. 🚀 Request permissions when appropriate
3. 📱 Test local notifications
4. 🔥 Add Firebase for push notifications (optional)
5. 🎨 Customize notification appearance
6. 📊 Track notification analytics

---

**Your app now has a production-ready notification system!** 🎉

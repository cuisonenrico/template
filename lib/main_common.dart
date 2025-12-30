import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/store/app_state.dart';
import 'core/config/app_flavor.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/storage_helper.dart';
import 'core/utils/app_logger.dart';
import 'core/services/hive_service.dart';
import 'core/services/notifications/notification_manager.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crash_reporting_service.dart';
import 'features/auth/controllers/auth_actions.dart';
import 'features/theme/controllers/theme_actions.dart';
import 'features/notifications/controllers/notification_actions.dart';

/// Set to true if you want to use Firebase Auth
/// Set to false to use OAuth endpoints only (no Firebase dependency)
const bool useFirebaseAuth = false;

void mainCommon(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set flavor
  AppFlavor.setFlavor(flavor);

  // Initialize Firebase only if needed
  if (useFirebaseAuth) {
    try {
      await Firebase.initializeApp();
      AppLogger().info('Firebase initialized');
    } catch (e) {
      AppLogger().warning('Firebase initialization failed: $e');
    }
  }

  // Initialize logger
  AppLogger().init();

  // Initialize crash reporting
  await CrashReportingService().init(
    kDebugMode ? DebugCrashReportingProvider() : DebugCrashReportingProvider(),
    // TODO: Replace with FirebaseCrashlyticsProvider() or SentryProvider() for production
  );

  // Initialize analytics
  await AnalyticsService().init(
    kDebugMode ? DebugAnalyticsProvider() : DebugAnalyticsProvider(),
    // TODO: Replace with your analytics provider for production
  );

  // Initialize connectivity monitoring
  await ConnectivityService().init();

  // Initialize Hive database
  await HiveService().init();

  // Initialize storage
  await StorageHelper.init();

  // Initialize notifications
  await NotificationManager().initialize();

  // Create store
  final store = Store<AppState>(initialState: AppState.initialState());

  // Check authentication status
  store.dispatch(CheckAuthStatusAction());

  // Load saved theme preference
  store.dispatch(LoadThemeAction());

  // Initialize notifications
  store.dispatch(InitializeNotificationsAction());

  // Log flavor info
  AppLogger().info('🚀 App started', {
    'flavor': flavor.name,
    'apiBaseUrl': flavor.apiBaseUrl,
    'environment': flavor.isDevelopment ? 'development' : 'production',
  });

  runApp(MyApp(store: store));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: StoreConnector<AppState, AppThemeMode>(
        converter: (store) => store.state.theme.themeMode,
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppFlavor.current.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode.themeMode,
            routerConfig: AppRouter.createRouter(store),
            debugShowCheckedModeBanner: !AppFlavor.current.isProduction,
          );
        },
      ),
    );
  }
}

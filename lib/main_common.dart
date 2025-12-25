import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'core/store/app_state.dart';
import 'core/config/app_flavor.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/storage_helper.dart';
import 'core/utils/app_logger.dart';
import 'core/services/hive_service.dart';
import 'core/services/notifications/notification_manager.dart';
import 'features/auth/controllers/auth_actions.dart';
import 'features/theme/controllers/theme_actions.dart';
import 'features/notifications/controllers/notification_actions.dart';

void mainCommon(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set flavor
  AppFlavor.setFlavor(flavor);

  // Initialize logger
  AppLogger().init();

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
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: !AppFlavor.current.isProduction,
          );
        },
      ),
    );
  }
}

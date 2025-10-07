import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import 'core/store/app_state.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/utils/storage_helper.dart';
import 'features/auth/controllers/auth_actions.dart';
import 'features/theme/controllers/theme_actions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await StorageHelper.init();

  // Create store
  final store = Store<AppState>(initialState: AppState.initialState());

  // Check authentication status
  store.dispatch(CheckAuthStatusAction());

  // Load saved theme preference
  store.dispatch(LoadThemeAction());

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
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

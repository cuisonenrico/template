import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/constants/app_theme.dart';

// Change Theme Action
class ChangeThemeAction extends ReduxAction<AppState> {
  final AppThemeMode themeMode;

  ChangeThemeAction(this.themeMode);

  @override
  Future<AppState?> reduce() async {
    // Save theme preference to local storage
    await StorageHelper.saveThemeMode(themeMode);

    // Update app state
    return state.copyWith(
      theme: state.theme.copyWith(themeMode: themeMode, isLoading: false),
    );
  }
}

// Load Saved Theme Action
class LoadThemeAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    dispatch(SetThemeLoadingAction(isLoading: true));

    try {
      final savedThemeMode = await StorageHelper.getThemeMode();

      return state.copyWith(
        theme: state.theme.copyWith(
          themeMode: savedThemeMode,
          isLoading: false,
        ),
      );
    } catch (e) {
      // If error loading theme, use system default
      return state.copyWith(
        theme: state.theme.copyWith(
          themeMode: AppThemeMode.system,
          isLoading: false,
        ),
      );
    }
  }
}

// Set Theme Loading Action
class SetThemeLoadingAction extends ReduxAction<AppState> {
  final bool isLoading;

  SetThemeLoadingAction({required this.isLoading});

  @override
  AppState? reduce() {
    return state.copyWith(theme: state.theme.copyWith(isLoading: isLoading));
  }
}

// Toggle Theme Action (Light <-> Dark)
class ToggleThemeAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final currentMode = state.theme.themeMode;
    final newMode = currentMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;

    dispatch(ChangeThemeAction(newMode));
    return null;
  }
}

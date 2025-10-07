import 'package:freezed_annotation/freezed_annotation.dart';
import '../../constants/app_theme.dart';

part 'theme_state.freezed.dart';
part 'theme_state.g.dart';

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(false) bool isLoading,
  }) = _ThemeState;

  factory ThemeState.fromJson(Map<String, dynamic> json) =>
      _$ThemeStateFromJson(json);

  factory ThemeState.initialState() => const ThemeState();
}

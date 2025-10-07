import 'package:freezed_annotation/freezed_annotation.dart';
import 'substates/auth_state.dart';
import 'substates/counter_state.dart';
import 'substates/theme_state.dart';

part 'app_state.freezed.dart';
part 'app_state.g.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(AuthState()) AuthState auth,
    @Default(CounterState()) CounterState counter,
    @Default(ThemeState()) ThemeState theme,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);

  factory AppState.initialState() => const AppState();
}

abstract class StateSerializer<St> {
  Map<String, dynamic> encode(St state);

  St decode(Map<String, dynamic> data);
}

class AppStateSerializer extends StateSerializer<AppState> {
  @override
  AppState decode(Map<String, dynamic> data) => AppState.fromJson(data);

  @override
  Map<String, dynamic> encode(AppState state) => state.toJson();
}

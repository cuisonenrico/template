import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_state.freezed.dart';
part 'counter_state.g.dart';

@freezed
class CounterState with _$CounterState {
  const factory CounterState({
    @Default(0) int value,
    @Default(false) bool isLoading,
    String? error,
  }) = _CounterState;

  factory CounterState.fromJson(Map<String, dynamic> json) =>
      _$CounterStateFromJson(json);

  factory CounterState.initialState() => const CounterState();
}

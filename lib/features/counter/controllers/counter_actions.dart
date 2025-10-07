import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';

// Increment Counter Action
class IncrementCounterAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(
      counter: state.counter.copyWith(value: state.counter.value + 1),
    );
  }
}

// Decrement Counter Action
class DecrementCounterAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(
      counter: state.counter.copyWith(value: state.counter.value - 1),
    );
  }
}

// Reset Counter Action
class ResetCounterAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(counter: state.counter.copyWith(value: 0));
  }
}

// Set Counter Value Action
class SetCounterValueAction extends ReduxAction<AppState> {
  final int value;

  SetCounterValueAction(this.value);

  @override
  AppState? reduce() {
    return state.copyWith(counter: state.counter.copyWith(value: value));
  }
}

// Async Increment Action (simulates API call)
class AsyncIncrementCounterAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // Set loading state
    dispatch(SetCounterLoadingAction(true));

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Increment counter
    final newValue = state.counter.value + 1;

    // Update state with new value and clear loading
    return state.copyWith(
      counter: state.counter.copyWith(
        value: newValue,
        isLoading: false,
        error: null,
      ),
    );
  }
}

// Set Counter Loading Action
class SetCounterLoadingAction extends ReduxAction<AppState> {
  final bool isLoading;

  SetCounterLoadingAction(this.isLoading);

  @override
  AppState? reduce() {
    return state.copyWith(
      counter: state.counter.copyWith(isLoading: isLoading, error: null),
    );
  }
}

// Set Counter Error Action
class SetCounterErrorAction extends ReduxAction<AppState> {
  final String error;

  SetCounterErrorAction(this.error);

  @override
  AppState? reduce() {
    return state.copyWith(
      counter: state.counter.copyWith(isLoading: false, error: error),
    );
  }
}

// Clear Counter Error Action
class ClearCounterErrorAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(counter: state.counter.copyWith(error: null));
  }
}

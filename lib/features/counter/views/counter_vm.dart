import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../controllers/counter_actions.dart';

/// ViewModel for the Counter feature
class CounterVm extends Vm {
  CounterVm({
    required this.value,
    required this.isLoading,
    required this.error,
    required this.onIncrement,
    required this.onDecrement,
    required this.onReset,
    required this.onAsyncIncrement,
    required this.onClearError,
    required this.onSetValue,
  });

  final int value;
  final bool isLoading;
  final String? error;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onReset;
  final VoidCallback onAsyncIncrement;
  final VoidCallback onClearError;
  final Function(int) onSetValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterVm &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          isLoading == other.isLoading &&
          error == other.error);

  @override
  int get hashCode => value.hashCode ^ isLoading.hashCode ^ error.hashCode;
}

/// Factory for creating CounterVm instances
class CounterVmFactory extends VmFactory<AppState, Widget, CounterVm> {
  @override
  CounterVm fromStore() {
    return CounterVm(
      value: state.counter.value,
      isLoading: state.counter.isLoading,
      error: state.counter.error,
      onIncrement: () => dispatch(IncrementCounterAction()),
      onDecrement: () => dispatch(DecrementCounterAction()),
      onReset: () => dispatch(ResetCounterAction()),
      onAsyncIncrement: () => dispatch(AsyncIncrementCounterAction()),
      onClearError: () => dispatch(ClearCounterErrorAction()),
      onSetValue: (value) => dispatch(SetCounterValueAction(value)),
    );
  }
}

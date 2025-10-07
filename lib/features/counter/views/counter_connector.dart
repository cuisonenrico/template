import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import 'counter_screen.dart';
import 'counter_vm.dart';

/// Connector that bridges the Redux store with the Counter screen
class CounterConnector extends StatelessWidget {
  const CounterConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, CounterVm>(
      vm: () => CounterVmFactory(),
      builder: (context, vm) {
        return CounterScreen(
          value: vm.value,
          isLoading: vm.isLoading,
          error: vm.error,
          onIncrement: vm.onIncrement,
          onDecrement: vm.onDecrement,
          onReset: vm.onReset,
          onAsyncIncrement: vm.onAsyncIncrement,
          onClearError: vm.onClearError,
          onSetValue: vm.onSetValue,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import 'register_screen.dart';
import 'register_vm.dart';

/// Connector that bridges the Redux store with the Register screen
class RegisterConnector extends StatelessWidget {
  const RegisterConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RegisterVm>(
      vm: () => RegisterVmFactory(),
      builder: (context, vm) {
        return RegisterScreen(
          isLoading: vm.isLoading,
          error: vm.error,
          onClearError: vm.onClearError,
          onRegister: vm.onRegister,
        );
      },
    );
  }
}

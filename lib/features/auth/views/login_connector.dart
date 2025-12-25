import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import 'login_screen.dart';
import 'login_vm.dart';

/// Connector that bridges the Redux store with the Login screen
class LoginConnector extends StatelessWidget {
  const LoginConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, LoginVm>(
      vm: () => LoginVmFactory(),
      builder: (context, vm) {
        return LoginScreen(
          isLoading: vm.isLoading,
          error: vm.error,
          onClearError: vm.onClearError,
          onLogin: vm.onLogin,
          onGoogleSignIn: vm.onGoogleSignIn,
        );
      },
    );
  }
}

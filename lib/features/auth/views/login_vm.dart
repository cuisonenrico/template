import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../controllers/auth_actions.dart';

/// ViewModel for the Login feature
class LoginVm extends Vm {
  LoginVm({
    required this.isLoading,
    required this.isLoggedIn,
    required this.error,
    required this.onClearError,
    required this.onLogin,
  });

  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final VoidCallback onClearError;
  final Function(String email, String password) onLogin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoginVm &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoggedIn == other.isLoggedIn &&
          error == other.error);

  @override
  int get hashCode => isLoading.hashCode ^ isLoggedIn.hashCode ^ error.hashCode;
}

/// Factory for creating LoginVm instances
class LoginVmFactory extends VmFactory<AppState, Widget, LoginVm> {
  @override
  LoginVm fromStore() {
    return LoginVm(
      isLoading: state.auth.isLoading,
      isLoggedIn: state.auth.isLoggedIn,
      error: state.auth.error,
      onClearError: () => dispatch(ClearAuthErrorAction()),
      onLogin: (email, password) =>
          dispatch(LoginAction(email: email, password: password)),
    );
  }
}

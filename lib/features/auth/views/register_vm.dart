import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../controllers/auth_actions.dart';

/// ViewModel for the Register feature
class RegisterVm extends Vm {
  RegisterVm({
    required this.isLoading,
    required this.isLoggedIn,
    required this.error,
    required this.onClearError,
    required this.onRegister,
  });

  final bool isLoading;
  final bool isLoggedIn;
  final String? error;
  final VoidCallback onClearError;
  final Function(String name, String email, String password) onRegister;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegisterVm &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoggedIn == other.isLoggedIn &&
          error == other.error);

  @override
  int get hashCode => isLoading.hashCode ^ isLoggedIn.hashCode ^ error.hashCode;
}

/// Factory for creating RegisterVm instances
class RegisterVmFactory extends VmFactory<AppState, Widget, RegisterVm> {
  @override
  RegisterVm fromStore() {
    return RegisterVm(
      isLoading: state.auth.isLoading,
      isLoggedIn: state.auth.isLoggedIn,
      error: state.auth.error,
      onClearError: () => dispatch(ClearAuthErrorAction()),
      onRegister: (name, email, password) => dispatch(
        RegisterAction(email: email, password: password, name: name),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../core/store/app_state.dart';
import '../../features/auth/controllers/auth_actions.dart';
import '../../features/auth/models/auth_models.dart' show User;

/// ViewModel for the Home screen
class HomeVm extends Vm {
  HomeVm({required this.user, required this.onLogout});

  final User? user;
  final VoidCallback onLogout;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeVm &&
          runtimeType == other.runtimeType &&
          user == other.user);

  @override
  int get hashCode => user.hashCode;
}

/// Factory for creating HomeVm instances
class HomeVmFactory extends VmFactory<AppState, Widget, HomeVm> {
  @override
  HomeVm fromStore() {
    return HomeVm(
      user: state.auth.user,
      onLogout: () => dispatch(LogoutAction()),
    );
  }
}

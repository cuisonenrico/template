import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../core/store/app_state.dart';
import 'home_screen.dart';
import 'home_vm.dart';

/// Connector that bridges the Redux store with the Home screen
class HomeConnector extends StatelessWidget {
  const HomeConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeVm>(
      vm: () => HomeVmFactory(),
      builder: (context, vm) {
        return HomeScreen(user: vm.user, onLogout: vm.onLogout);
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../controllers/{{name.snakeCase()}}_actions.dart';
import '{{name.snakeCase()}}_screen.dart';
import '{{name.snakeCase()}}_vm.dart';

/// Connector that bridges the Redux store with the {{name.titleCase()}} screen
class {{name.pascalCase()}}Connector extends StatelessWidget {
  const {{name.pascalCase()}}Connector({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, {{name.pascalCase()}}Vm>(
      vm: () => {{name.pascalCase()}}VmFactory(),
      onInit: (store) => store.dispatch(Fetch{{name.pascalCase()}}ListAction()),
      builder: (context, vm) {
        return {{name.pascalCase()}}Screen(
          items: vm.items,
          isLoading: vm.isLoading,
          error: vm.error,
          selected{{name.pascalCase()}}: vm.selected{{name.pascalCase()}},
          onRefresh: vm.onRefresh,
          onSelect: vm.onSelect,
          onDelete: vm.onDelete,
          onClearError: vm.onClearError,
        );
      },
    );
  }
}
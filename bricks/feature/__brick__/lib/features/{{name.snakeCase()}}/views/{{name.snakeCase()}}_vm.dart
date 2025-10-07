import 'package:flutter/material.dart';
import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../controllers/{{name.snakeCase()}}_actions.dart';
import '../models/{{name.snakeCase()}}_models.dart';

/// ViewModel for the {{name.titleCase()}} feature
class {{name.pascalCase()}}Vm extends Vm {
  {{name.pascalCase()}}Vm({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.selected{{name.pascalCase()}},
    required this.onRefresh,
    required this.onSelect,
    required this.onDelete,
    required this.onClearError,
  });

  final List<{{name.pascalCase()}}> items;
  final bool isLoading;
  final String? error;
  final {{name.pascalCase()}}? selected{{name.pascalCase()}};
  final VoidCallback onRefresh;
  final Function({{name.pascalCase()}}) onSelect;
  final Function(String) onDelete;
  final VoidCallback onClearError;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is {{name.pascalCase()}}Vm &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          isLoading == other.isLoading &&
          error == other.error &&
          selected{{name.pascalCase()}} == other.selected{{name.pascalCase()}});

  @override
  int get hashCode => 
      items.hashCode ^ 
      isLoading.hashCode ^ 
      error.hashCode ^ 
      selected{{name.pascalCase()}}.hashCode;
}

/// Factory for creating {{name.pascalCase()}}Vm instances
class {{name.pascalCase()}}VmFactory extends VmFactory<AppState, Widget, {{name.pascalCase()}}Vm> {
  @override
  {{name.pascalCase()}}Vm fromStore() {
    return {{name.pascalCase()}}Vm(
      items: state.{{name.camelCase()}}.items,
      isLoading: state.{{name.camelCase()}}.isLoading,
      error: state.{{name.camelCase()}}.error,
      selected{{name.pascalCase()}}: state.{{name.camelCase()}}.selected{{name.pascalCase()}},
      onRefresh: () => dispatch(Fetch{{name.pascalCase()}}ListAction()),
      onSelect: ({{name.camelCase()}}) => dispatch(Select{{name.pascalCase()}}Action({{name.camelCase()}})),
      onDelete: (id) => dispatch(Delete{{name.pascalCase()}}Action(id)),
      onClearError: () => dispatch(Clear{{name.pascalCase()}}ErrorAction()),
    );
  }
}
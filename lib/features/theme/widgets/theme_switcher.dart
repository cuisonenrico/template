import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/store/app_state.dart';
import '../controllers/theme_actions.dart';

/// A versatile theme switcher widget that can be used as a button, switch, or dropdown
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key, this.type = ThemeSwitcherType.iconButton, this.showLabel = true});

  final ThemeSwitcherType type;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ThemeSwitcherVm>(
      vm: () => ThemeSwitcherVmFactory(),
      builder: (context, vm) {
        switch (type) {
          case ThemeSwitcherType.iconButton:
            return _IconButtonSwitcher(vm: vm, showLabel: showLabel);
          case ThemeSwitcherType.dropdown:
            return _DropdownSwitcher(vm: vm, showLabel: showLabel);
          case ThemeSwitcherType.segmentedButton:
            return _SegmentedButtonSwitcher(vm: vm, showLabel: showLabel);
          case ThemeSwitcherType.listTile:
            return _ListTileSwitcher(vm: vm);
        }
      },
    );
  }
}

enum ThemeSwitcherType { iconButton, dropdown, segmentedButton, listTile }

/// ViewModel for theme switcher
class ThemeSwitcherVm extends Vm {
  ThemeSwitcherVm({required this.currentTheme, required this.isLoading, required this.onThemeChanged});

  final AppThemeMode currentTheme;
  final bool isLoading;
  final Function(AppThemeMode) onThemeChanged;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeSwitcherVm &&
          runtimeType == other.runtimeType &&
          currentTheme == other.currentTheme &&
          isLoading == other.isLoading);

  @override
  int get hashCode => currentTheme.hashCode ^ isLoading.hashCode;
}

class ThemeSwitcherVmFactory extends VmFactory<AppState, Widget, ThemeSwitcherVm> {
  @override
  ThemeSwitcherVm fromStore() {
    return ThemeSwitcherVm(
      currentTheme: state.theme.themeMode,
      isLoading: state.theme.isLoading,
      onThemeChanged: (themeMode) => dispatch(ChangeThemeAction(themeMode)),
    );
  }
}

/// Icon Button Theme Switcher
class _IconButtonSwitcher extends StatelessWidget {
  const _IconButtonSwitcher({required this.vm, required this.showLabel});

  final ThemeSwitcherVm vm;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(vm.currentTheme.icon),
          onPressed: vm.isLoading
              ? null
              : () {
                  final nextTheme = _getNextTheme(vm.currentTheme);
                  vm.onThemeChanged(nextTheme);
                },
          tooltip: 'Switch to ${_getNextTheme(vm.currentTheme).displayName} theme',
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(vm.currentTheme.displayName, style: Theme.of(context).textTheme.labelMedium),
        ],
      ],
    );
  }

  AppThemeMode _getNextTheme(AppThemeMode current) {
    switch (current) {
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.system;
      case AppThemeMode.system:
        return AppThemeMode.light;
    }
  }
}

/// Dropdown Theme Switcher
class _DropdownSwitcher extends StatelessWidget {
  const _DropdownSwitcher({required this.vm, required this.showLabel});

  final ThemeSwitcherVm vm;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[Text('Theme: ', style: Theme.of(context).textTheme.labelMedium), const SizedBox(width: 8)],
        DropdownButton<AppThemeMode>(
          value: vm.currentTheme,
          onChanged: vm.isLoading
              ? null
              : (AppThemeMode? newTheme) {
                  if (newTheme != null) {
                    vm.onThemeChanged(newTheme);
                  }
                },
          items: AppThemeMode.values.map((AppThemeMode mode) {
            return DropdownMenuItem<AppThemeMode>(
              value: mode,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(mode.icon, size: 16), const SizedBox(width: 8), Text(mode.displayName)],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Segmented Button Theme Switcher
class _SegmentedButtonSwitcher extends StatelessWidget {
  const _SegmentedButtonSwitcher({required this.vm, required this.showLabel});

  final ThemeSwitcherVm vm;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[Text('Theme', style: Theme.of(context).textTheme.labelMedium), const SizedBox(height: 8)],
        SegmentedButton<AppThemeMode>(
          segments: AppThemeMode.values.map((mode) {
            return ButtonSegment<AppThemeMode>(value: mode, icon: Icon(mode.icon), label: Text(mode.displayName));
          }).toList(),
          selected: {vm.currentTheme},
          onSelectionChanged: vm.isLoading
              ? null
              : (Set<AppThemeMode> selection) {
                  if (selection.isNotEmpty) {
                    vm.onThemeChanged(selection.first);
                  }
                },
        ),
      ],
    );
  }
}

/// List Tile Theme Switcher
class _ListTileSwitcher extends StatelessWidget {
  const _ListTileSwitcher({required this.vm});

  final ThemeSwitcherVm vm;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(vm.currentTheme.icon),
      title: const Text('Theme'),
      subtitle: Text(vm.currentTheme.displayName),
      children: [
        RadioGroup<AppThemeMode>(
          groupValue: vm.currentTheme,
          onChanged: (AppThemeMode? value) {
            if (!vm.isLoading && value != null) {
              vm.onThemeChanged(value);
            }
          },
          child: Column(
            children: AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                value: mode,
                secondary: Icon(mode.icon),
                title: Text(mode.displayName),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

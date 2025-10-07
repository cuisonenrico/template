import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
{{#has_api}}import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
{{/has_api}}import '../models/{{name.snakeCase()}}_models.dart';

// Fetch {{name.pascalCase()}} List Action
class Fetch{{name.pascalCase()}}ListAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));

    try {
{{#has_api}}      final apiService = ApiService();
      final response = await apiService.get('/{{name.kebabCase()}}', requiresAuth: true);

      if (response.success && response.data != null) {
        final items = (response.data!['data'] as List)
            .map((json) => {{name.pascalCase()}}.fromJson(json))
            .toList();

        return state.copyWith(
          {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
            items: items,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        dispatch(Set{{name.pascalCase()}}ErrorAction(response.message ?? 'Failed to fetch {{name.titleCase()}}'));
        return null;
      }
{{/has_api}}{{^has_api}}      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final items = <{{name.pascalCase()}}>[];

      return state.copyWith(
        {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
          items: items,
          isLoading: false,
          error: null,
        ),
      );
{{/has_api}}    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}

{{#has_api}}// Create {{name.pascalCase()}} Action
class Create{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final {{name.pascalCase()}} {{name.camelCase()}};

  Create{{name.pascalCase()}}Action(this.{{name.camelCase()}});

  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));

    try {
      final apiService = ApiService();
      final response = await apiService.post(
        '/{{name.kebabCase()}}',
        {{name.camelCase()}}.toJson(),
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final new{{name.pascalCase()}} = {{name.pascalCase()}}.fromJson(response.data!);
        final updatedItems = [...state.{{name.camelCase()}}.items, new{{name.pascalCase()}}];

        return state.copyWith(
          {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
            items: updatedItems,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        dispatch(Set{{name.pascalCase()}}ErrorAction(response.message ?? 'Failed to create {{name.titleCase()}}'));
        return null;
      }
    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}

// Update {{name.pascalCase()}} Action
class Update{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final {{name.pascalCase()}} {{name.camelCase()}};

  Update{{name.pascalCase()}}Action(this.{{name.camelCase()}});

  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));

    try {
      final apiService = ApiService();
      final response = await apiService.put(
        '/{{name.kebabCase()}}/${{{name.camelCase()}}.id}',
        {{name.camelCase()}}.toJson(),
        requiresAuth: true,
      );

      if (response.success && response.data != null) {
        final updated{{name.pascalCase()}} = {{name.pascalCase()}}.fromJson(response.data!);
        final updatedItems = state.{{name.camelCase()}}.items
            .map((item) => item.id == updated{{name.pascalCase()}}.id ? updated{{name.pascalCase()}} : item)
            .toList();

        return state.copyWith(
          {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
            items: updatedItems,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        dispatch(Set{{name.pascalCase()}}ErrorAction(response.message ?? 'Failed to update {{name.titleCase()}}'));
        return null;
      }
    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}

// Delete {{name.pascalCase()}} Action
class Delete{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final String {{name.camelCase()}}Id;

  Delete{{name.pascalCase()}}Action(this.{{name.camelCase()}}Id);

  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));

    try {
      final apiService = ApiService();
      final response = await apiService.delete(
        '/{{name.kebabCase()}}/${{name.camelCase()}}Id',
        requiresAuth: true,
      );

      if (response.success) {
        final updatedItems = state.{{name.camelCase()}}.items
            .where((item) => item.id != {{name.camelCase()}}Id)
            .toList();

        return state.copyWith(
          {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
            items: updatedItems,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        dispatch(Set{{name.pascalCase()}}ErrorAction(response.message ?? 'Failed to delete {{name.titleCase()}}'));
        return null;
      }
    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}

{{/has_api}}// Select {{name.pascalCase()}} Action
class Select{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final {{name.pascalCase()}}? {{name.camelCase()}};

  Select{{name.pascalCase()}}Action(this.{{name.camelCase()}});

  @override
  AppState? reduce() {
    return state.copyWith(
      {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
        selected{{name.pascalCase()}}: {{name.camelCase()}},
      ),
    );
  }
}

// Set {{name.pascalCase()}} Loading Action
class Set{{name.pascalCase()}}LoadingAction extends ReduxAction<AppState> {
  final bool isLoading;

  Set{{name.pascalCase()}}LoadingAction(this.isLoading);

  @override
  AppState? reduce() {
    return state.copyWith(
      {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(isLoading: isLoading),
    );
  }
}

// Set {{name.pascalCase()}} Error Action
class Set{{name.pascalCase()}}ErrorAction extends ReduxAction<AppState> {
  final String error;

  Set{{name.pascalCase()}}ErrorAction(this.error);

  @override
  AppState? reduce() {
    return state.copyWith(
      {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
        isLoading: false,
        error: error,
      ),
    );
  }
}

// Clear {{name.pascalCase()}} Error Action
class Clear{{name.pascalCase()}}ErrorAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(
      {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(error: null),
    );
  }
}
import 'package:async_redux/async_redux.dart';
import 'package:hive/hive.dart';
import '../../../core/store/app_state.dart';
{{#has_api}}import '../../../core/services/api_service.dart';
import '../../../core/constants/app_constants.dart';
{{/has_api}}import '../../../core/services/hive_service.dart';
import '../models/{{name.snakeCase()}}_models.dart';

// Hive box name
const String _{{name.camelCase()}}BoxName = '{{name.snakeCase()}}_box';

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

        // Cache in Hive
        await _cacheItems(items);

        return state.copyWith(
          {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
            items: items,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        // Try loading from Hive cache
        final cachedItems = await _loadFromCache();
        if (cachedItems.isNotEmpty) {
          return state.copyWith(
            {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
              items: cachedItems,
              isLoading: false,
              error: null,
            ),
          );
        }
        
        dispatch(Set{{name.pascalCase()}}ErrorAction(response.message ?? 'Failed to fetch {{name.titleCase()}}'));
        return null;
      }
{{/has_api}}{{^has_api}}      // Load from Hive
      final items = await _loadFromCache();

      return state.copyWith(
        {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
          items: items,
          isLoading: false,
          error: null,
        ),
      );
{{/has_api}}    } catch (e) {
      // Try loading from Hive cache on error
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(
          {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
            items: cachedItems,
            isLoading: false,
            error: null,
          ),
        );
      }
      
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }

  Future<List<{{name.pascalCase()}}>> _loadFromCache() async {
    try {
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _cacheItems(List<{{name.pascalCase()}}> items) async {
    try {
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      await box.clear();
      for (final item in items) {
        await box.add(item);
      }
    } catch (e) {
      // Ignore cache errors
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
        
        // Add to Hive
        await _addToCache(new{{name.pascalCase()}});
        
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

  Future<void> _addToCache({{name.pascalCase()}} item) async {
    try {
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      await box.add(item);
    } catch (e) {
      // Ignore cache errors
    }
  }
}
{{/has_api}}{{^has_api}}// Create {{name.pascalCase()}} Action (Local only)
class Create{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final {{name.pascalCase()}} {{name.camelCase()}};

  Create{{name.pascalCase()}}Action(this.{{name.camelCase()}});

  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));
    
    try {
      // Add to Hive
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      await box.add({{name.camelCase()}});
      
      final updatedItems = [...state.{{name.camelCase()}}.items, {{name.camelCase()}}];

      return state.copyWith(
        {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
          items: updatedItems,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}
{{/has_api}}

{{#has_api}}// Update {{name.pascalCase()}} Action
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
        
        // Update in Hive
        await _updateInCache(updated{{name.pascalCase()}});
        
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

  Future<void> _updateInCache({{name.pascalCase()}} item) async {
    try {
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      final index = box.values.toList().indexWhere((i) => i.id == item.id);
      if (index != -1) {
        await box.putAt(index, item);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }
}
{{/has_api}}{{^has_api}}// Update {{name.pascalCase()}} Action (Local only)
class Update{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final int index;
  final {{name.pascalCase()}} {{name.camelCase()}};

  Update{{name.pascalCase()}}Action(this.index, this.{{name.camelCase()}});

  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));
    
    try {
      // Update in Hive
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      await box.putAt(index, {{name.camelCase()}});
      
      final updatedItems = List<{{name.pascalCase()}}>.from(state.{{name.camelCase()}}.items);
      updatedItems[index] = {{name.camelCase()}};

      return state.copyWith(
        {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
          items: updatedItems,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}
{{/has_api}}

{{#has_api}}// Delete {{name.pascalCase()}} Action
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
        // Delete from Hive
        await _deleteFromCache({{name.camelCase()}}Id);
        
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

  Future<void> _deleteFromCache(String id) async {
    try {
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      final index = box.values.toList().indexWhere((i) => i.id == id);
      if (index != -1) {
        await box.deleteAt(index);
      }
    } catch (e) {
      // Ignore cache errors
    }
  }
}
{{/has_api}}{{^has_api}}// Delete {{name.pascalCase()}} Action (Local only)
class Delete{{name.pascalCase()}}Action extends ReduxAction<AppState> {
  final int index;

  Delete{{name.pascalCase()}}Action(this.index);

  @override
  Future<AppState?> reduce() async {
    dispatch(Set{{name.pascalCase()}}LoadingAction(true));
    
    try {
      // Delete from Hive
      final box = await HiveService().openBox<{{name.pascalCase()}}>(_{{name.camelCase()}}BoxName);
      await box.deleteAt(index);
      
      final updatedItems = List<{{name.pascalCase()}}>.from(state.{{name.camelCase()}}.items);
      updatedItems.removeAt(index);

      return state.copyWith(
        {{name.camelCase()}}: state.{{name.camelCase()}}.copyWith(
          items: updatedItems,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      dispatch(Set{{name.pascalCase()}}ErrorAction(e.toString()));
      return null;
    }
  }
}
{{/has_api}}

// Select {{name.pascalCase()}} Action
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

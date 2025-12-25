import 'package:flutter_test/flutter_test.dart';
import 'package:async_redux/async_redux.dart';
import 'package:template/core/store/app_state.dart';
import 'package:template/features/{{name.snakeCase()}}/controllers/{{name.snakeCase()}}_actions.dart';
import 'package:template/features/{{name.snakeCase()}}/models/{{name.snakeCase()}}_models.dart';

void main() {
  group('{{name.pascalCase()}} Actions', () {
    late Store<AppState> store;

    setUp(() {
      store = Store<AppState>(initialState: AppState.initialState());
    });

    test('Fetch{{name.pascalCase()}}ListAction updates state', () async {
      await store.dispatchAndWait(Fetch{{name.pascalCase()}}ListAction());

      expect(store.state.{{name.camelCase()}}.isLoading, false);
      expect(store.state.{{name.camelCase()}}.error, null);
    });

    test('Set{{name.pascalCase()}}LoadingAction sets loading state', () async {
      await store.dispatchAndWait(Set{{name.pascalCase()}}LoadingAction(true));

      expect(store.state.{{name.camelCase()}}.isLoading, true);
    });

    test('Set{{name.pascalCase()}}ErrorAction sets error message', () async {
      const errorMessage = 'Test error';
      await store.dispatchAndWait(Set{{name.pascalCase()}}ErrorAction(errorMessage));

      expect(store.state.{{name.camelCase()}}.error, errorMessage);
      expect(store.state.{{name.camelCase()}}.isLoading, false);
    });
  });

  group('{{name.pascalCase()}} Model', () {
    test('{{name.pascalCase()}}.fromJson creates valid model', () {
      final json = {
        'id': '1',
        'name': 'Test {{name.titleCase()}}',
      };

      final {{name.camelCase()}} = {{name.pascalCase()}}.fromJson(json);

      expect({{name.camelCase()}}.id, '1');
      expect({{name.camelCase()}}.name, 'Test {{name.titleCase()}}');
    });

    test('{{name.pascalCase()}}.toJson creates valid json', () {
      final {{name.camelCase()}} = {{name.pascalCase()}}(
        id: '1',
        name: 'Test {{name.titleCase()}}',
      );

      final json = {{name.camelCase()}}.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Test {{name.titleCase()}}');
    });
  });
}

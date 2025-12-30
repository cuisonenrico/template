import 'package:flutter_test/flutter_test.dart';
import 'package:async_redux/async_redux.dart';
import 'package:template/core/store/app_state.dart';
import 'package:template/core/store/substates/auth_state.dart';
import 'package:template/features/auth/models/auth_models.dart';
import 'package:template/features/counter/controllers/counter_actions.dart';

void main() {
  group('Counter Actions', () {
    late Store<AppState> store;

    setUp(() {
      store = Store<AppState>(initialState: AppState.initialState());
    });

    test('IncrementCounterAction increments counter by 1', () async {
      expect(store.state.counter.value, 0);

      await store.dispatchAndWait(IncrementCounterAction());

      expect(store.state.counter.value, 1);
    });

    test('DecrementCounterAction decrements counter by 1', () async {
      // Set initial value to 5
      store = Store<AppState>(
        initialState: AppState.initialState().copyWith(
          counter: store.state.counter.copyWith(value: 5),
        ),
      );

      await store.dispatchAndWait(DecrementCounterAction());

      expect(store.state.counter.value, 4);
    });

    test('ResetCounterAction resets counter to 0', () async {
      // Set initial value to 10
      store = Store<AppState>(
        initialState: AppState.initialState().copyWith(
          counter: store.state.counter.copyWith(value: 10),
        ),
      );

      await store.dispatchAndWait(ResetCounterAction());

      expect(store.state.counter.value, 0);
    });

    test('SetCounterValueAction sets counter to specific value', () async {
      await store.dispatchAndWait(SetCounterValueAction(42));

      expect(store.state.counter.value, 42);
    });

    test('Multiple increments work correctly', () async {
      await store.dispatchAndWait(IncrementCounterAction());
      await store.dispatchAndWait(IncrementCounterAction());
      await store.dispatchAndWait(IncrementCounterAction());

      expect(store.state.counter.value, 3);
    });

    test('Counter can go negative', () async {
      await store.dispatchAndWait(DecrementCounterAction());
      await store.dispatchAndWait(DecrementCounterAction());

      expect(store.state.counter.value, -2);
    });
  });

  group('Auth State', () {
    test('AuthState.initialState has correct defaults', () {
      final authState = AuthState.initialState();

      expect(authState.isLoggedIn, false);
      expect(authState.isLoading, false);
      expect(authState.user, isNull);
      expect(authState.error, isNull);
      expect(authState.accessToken, isNull);
      expect(authState.refreshToken, isNull);
    });

    test('AuthState.copyWith creates new instance with updated values', () {
      final initialState = AuthState.initialState();
      final user = User(id: '123', email: 'test@test.com');

      final updatedState = initialState.copyWith(
        isLoggedIn: true,
        user: user,
        accessToken: 'token123',
      );

      expect(updatedState.isLoggedIn, true);
      expect(updatedState.user, user);
      expect(updatedState.accessToken, 'token123');
      expect(updatedState.isLoading, false); // unchanged
      expect(updatedState.error, isNull); // unchanged
    });
  });

  group('User Model', () {
    test('User.fromJson parses correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.com',
        'name': 'Test User',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatar, 'https://example.com/avatar.jpg');
    });

    test('User.toJson produces correct output', () {
      final user = User(
        id: 'user-123',
        email: 'test@example.com',
        name: 'Test User',
        avatar: 'https://example.com/avatar.jpg',
      );

      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
    });

    test('User equality works correctly', () {
      final user1 = User(id: '123', email: 'test@test.com');
      final user2 = User(id: '123', email: 'test@test.com');
      final user3 = User(id: '456', email: 'other@test.com');

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });

  group('AppState', () {
    test('AppState.initialState creates valid initial state', () {
      final state = AppState.initialState();

      expect(state.auth, isNotNull);
      expect(state.counter, isNotNull);
      expect(state.theme, isNotNull);
    });

    test('AppState.copyWith preserves unchanged fields', () {
      final initialState = AppState.initialState();
      final newCounter = initialState.counter.copyWith(value: 100);

      final updatedState = initialState.copyWith(counter: newCounter);

      expect(updatedState.counter.value, 100);
      expect(updatedState.auth, initialState.auth); // unchanged
      expect(updatedState.theme, initialState.theme); // unchanged
    });
  });
}

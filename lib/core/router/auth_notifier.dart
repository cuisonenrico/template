import 'package:async_redux/async_redux.dart';
import 'package:flutter/foundation.dart';

import '../store/app_state.dart';

/// ChangeNotifier that listens to auth state changes in the Redux store
/// and notifies the router to re-evaluate redirects
class AuthNotifier extends ChangeNotifier {
  final Store<AppState> _store;
  bool _isLoggedIn = false;

  AuthNotifier(this._store) {
    _isLoggedIn = _store.state.auth.isLoggedIn;

    // Subscribe to store changes
    _store.onChange.listen((state) {
      final newIsLoggedIn = state.auth.isLoggedIn;
      if (newIsLoggedIn != _isLoggedIn) {
        _isLoggedIn = newIsLoggedIn;
        notifyListeners();
      }
    });
  }

  bool get isLoggedIn => _isLoggedIn;
}

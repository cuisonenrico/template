import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../../../core/store/substates/auth_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../models/auth_models.dart' as auth_models;

// Login Action
class LoginAction extends ReduxAction<AppState> {
  final String email;
  final String password;

  LoginAction({required this.email, required this.password});

  @override
  Future<AppState?> reduce() async {
    // Set loading state
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final loginRequest = auth_models.LoginRequest(
        email: email,
        password: password,
      );

      final response = await apiService.post(
        AppConstants.loginEndpoint,
        loginRequest.toJson(),
      );

      if (response.success && response.data != null) {
        final authResponse = auth_models.AuthResponse.fromJson(response.data!);

        // Store tokens and user data
        await StorageHelper.saveAccessToken(authResponse.accessToken);
        await StorageHelper.saveRefreshToken(authResponse.refreshToken);
        await StorageHelper.saveUserData(authResponse.user.toJson());
        await StorageHelper.setLoggedIn(true);

        // Update state
        return state.copyWith(
          auth: state.auth.copyWith(
            isLoggedIn: true,
            isLoading: false,
            user: authResponse.user,
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            error: null,
          ),
        );
      } else {
        dispatch(SetAuthErrorAction(error: response.message ?? 'Login failed'));
        return null;
      }
    } catch (e) {
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// Register Action
class RegisterAction extends ReduxAction<AppState> {
  final String email;
  final String password;
  final String? name;

  RegisterAction({required this.email, required this.password, this.name});

  @override
  Future<AppState?> reduce() async {
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final registerRequest = auth_models.RegisterRequest(
        email: email,
        password: password,
        name: name,
      );

      final response = await apiService.post(
        AppConstants.registerEndpoint,
        registerRequest.toJson(),
      );

      if (response.success && response.data != null) {
        final authResponse = auth_models.AuthResponse.fromJson(response.data!);

        // Store tokens and user data
        await StorageHelper.saveAccessToken(authResponse.accessToken);
        await StorageHelper.saveRefreshToken(authResponse.refreshToken);
        await StorageHelper.saveUserData(authResponse.user.toJson());
        await StorageHelper.setLoggedIn(true);

        // Update state
        return state.copyWith(
          auth: state.auth.copyWith(
            isLoggedIn: true,
            isLoading: false,
            user: authResponse.user,
            accessToken: authResponse.accessToken,
            refreshToken: authResponse.refreshToken,
            error: null,
          ),
        );
      } else {
        dispatch(
          SetAuthErrorAction(error: response.message ?? 'Registration failed'),
        );
        return null;
      }
    } catch (e) {
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// Logout Action
class LogoutAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();

      // Attempt to logout on server
      await apiService.post(
        AppConstants.logoutEndpoint,
        {},
        requiresAuth: true,
      );
    } catch (e) {
      // Continue with local logout even if server logout fails
    }

    // Clear local storage
    await StorageHelper.clearUserSession();

    // Update state
    return state.copyWith(auth: const AuthState());
  }
}

// Check Auth Status Action
class CheckAuthStatusAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final isLoggedIn = await StorageHelper.isLoggedIn();

    if (isLoggedIn) {
      final accessToken = await StorageHelper.getAccessToken();
      final refreshToken = await StorageHelper.getRefreshToken();
      final userData = await StorageHelper.getUserData();

      if (accessToken != null && userData != null) {
        final user = auth_models.User.fromJson(userData);

        return state.copyWith(
          auth: state.auth.copyWith(
            isLoggedIn: true,
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          ),
        );
      }
    }

    return null;
  }
}

// Refresh Token Action
class RefreshTokenAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      final refreshToken = await StorageHelper.getRefreshToken();

      if (refreshToken == null) {
        dispatch(LogoutAction());
        return null;
      }

      final apiService = ApiService();
      final response = await apiService.post(
        AppConstants.refreshTokenEndpoint,
        {'refresh_token': refreshToken},
      );

      if (response.success && response.data != null) {
        final newAccessToken = response.data!['access_token'];
        await StorageHelper.saveAccessToken(newAccessToken);

        return state.copyWith(
          auth: state.auth.copyWith(accessToken: newAccessToken),
        );
      } else {
        dispatch(LogoutAction());
        return null;
      }
    } catch (e) {
      dispatch(LogoutAction());
      return null;
    }
  }
}

// Helper Actions
class SetAuthLoadingAction extends ReduxAction<AppState> {
  final bool isLoading;

  SetAuthLoadingAction({required this.isLoading});

  @override
  AppState? reduce() {
    return state.copyWith(auth: state.auth.copyWith(isLoading: isLoading));
  }
}

class SetAuthErrorAction extends ReduxAction<AppState> {
  final String error;

  SetAuthErrorAction({required this.error});

  @override
  AppState? reduce() {
    return state.copyWith(
      auth: state.auth.copyWith(isLoading: false, error: error),
    );
  }
}

class ClearAuthErrorAction extends ReduxAction<AppState> {
  @override
  AppState? reduce() {
    return state.copyWith(auth: state.auth.copyWith(error: null));
  }
}

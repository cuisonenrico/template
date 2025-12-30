import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../../../core/store/substates/auth_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/utils/app_logger.dart';
import '../models/auth_models.dart' as auth_models;

// ============================================
// OAuth Login Action (Primary - No Firebase Required)
// ============================================
class LoginAction extends ReduxAction<AppState> {
  final String email;
  final String password;

  LoginAction({required this.email, required this.password});

  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final response = await apiService.oauthLogin(email, password);

      if (!response.success) {
        dispatch(SetAuthErrorAction(error: response.message ?? 'Login failed'));
        return null;
      }

      // Extract user from response
      final userData = response.data?['user'];
      if (userData == null) {
        dispatch(SetAuthErrorAction(error: 'Invalid response from server'));
        return null;
      }

      final user = auth_models.User(
        id: userData['id'] ?? '',
        email: userData['email'] ?? email,
        name: userData['name'],
        avatar: userData['avatarUrl'],
      );

      // Tokens are automatically stored by oauthLogin
      final accessToken = response.data?['accessToken'];
      final refreshToken = response.data?['refreshToken'];

      await StorageHelper.saveUserData(user.toJson());
      await StorageHelper.setLoggedIn(true);

      logger.info('User logged in successfully via OAuth', {
        'userId': user.id,
        'email': user.email,
      });

      return state.copyWith(
        auth: state.auth.copyWith(
          isLoggedIn: true,
          isLoading: false,
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger().error('OAuth login failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// ============================================
// OAuth Register Action (Primary - No Firebase Required)
// ============================================
class RegisterAction extends ReduxAction<AppState> {
  final String email;
  final String password;
  final String? name;

  RegisterAction({required this.email, required this.password, this.name});

  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final response = await apiService.oauthRegister(
        email,
        password,
        name: name,
      );

      if (!response.success) {
        dispatch(
          SetAuthErrorAction(error: response.message ?? 'Registration failed'),
        );
        return null;
      }

      // Extract user from response
      final userData = response.data?['user'];
      if (userData == null) {
        dispatch(SetAuthErrorAction(error: 'Invalid response from server'));
        return null;
      }

      final user = auth_models.User(
        id: userData['id'] ?? '',
        email: userData['email'] ?? email,
        name: userData['name'] ?? name,
        avatar: userData['avatarUrl'],
      );

      // Tokens are automatically stored by oauthRegister
      final accessToken = response.data?['accessToken'];
      final refreshToken = response.data?['refreshToken'];

      await StorageHelper.saveUserData(user.toJson());
      await StorageHelper.setLoggedIn(true);

      logger.info('User registered successfully via OAuth', {
        'userId': user.id,
        'email': user.email,
      });

      return state.copyWith(
        auth: state.auth.copyWith(
          isLoggedIn: true,
          isLoading: false,
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger().error('OAuth registration failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// ============================================
// OAuth Google Sign In Action
// Uses backend OAuth flow instead of Firebase
// ============================================
class GoogleSignInAction extends ReduxAction<AppState> {
  final String authorizationCode;

  GoogleSignInAction({required this.authorizationCode});

  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final response = await apiService.oauthCallback(
        'google',
        authorizationCode,
      );

      if (!response.success) {
        dispatch(
          SetAuthErrorAction(
            error: response.message ?? 'Google sign in failed',
          ),
        );
        return null;
      }

      // Extract user from response
      final userData = response.data?['user'];
      if (userData == null) {
        dispatch(SetAuthErrorAction(error: 'Invalid response from server'));
        return null;
      }

      final user = auth_models.User(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'],
        avatar: userData['avatarUrl'],
      );

      // Tokens are automatically stored by oauthCallback
      final accessToken = response.data?['accessToken'];
      final refreshToken = response.data?['refreshToken'];

      await StorageHelper.saveUserData(user.toJson());
      await StorageHelper.setLoggedIn(true);

      logger.info('User signed in with Google via OAuth', {
        'userId': user.id,
        'email': user.email,
      });

      return state.copyWith(
        auth: state.auth.copyWith(
          isLoggedIn: true,
          isLoading: false,
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger().error('Google OAuth sign in failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// ============================================
// Get OAuth URL Action (for initiating Google sign in)
// ============================================
class GetOAuthUrlAction extends ReduxAction<AppState> {
  final String provider;
  final void Function(String url)? onSuccess;
  final void Function(String error)? onError;

  GetOAuthUrlAction({this.provider = 'google', this.onSuccess, this.onError});

  @override
  Future<AppState?> reduce() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getOAuthUrl(provider);

      if (response.success && response.data?['url'] != null) {
        onSuccess?.call(response.data!['url']);
      } else {
        onError?.call(response.message ?? 'Failed to get OAuth URL');
      }
    } catch (e) {
      onError?.call(e.toString());
    }
    return null;
  }
}

// ============================================
// OAuth Logout Action
// ============================================
class LogoutAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      await apiService.oauthLogout();
      logger.info('User logged out via OAuth');
    } catch (e, stackTrace) {
      logger.error('OAuth logout error', e, stackTrace);
      // Continue with local logout even if server logout fails
    }

    // Clear local storage
    await StorageHelper.clearUserSession();

    // Update state
    return state.copyWith(auth: const AuthState());
  }
}

// ============================================
// Logout from All Devices Action
// ============================================
class LogoutAllDevicesAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      await apiService.oauthLogoutAll();
      logger.info('User logged out from all devices');
    } catch (e, stackTrace) {
      logger.error('Logout all devices error', e, stackTrace);
    }

    await StorageHelper.clearUserSession();
    return state.copyWith(auth: const AuthState());
  }
}

// ============================================
// Check Auth Status Action
// ============================================
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

        // Optionally verify token is still valid
        try {
          final apiService = ApiService();
          final response = await apiService.getOAuthProfile();
          if (!response.success) {
            // Token invalid, try refresh
            dispatch(RefreshTokenAction());
          }
        } catch (_) {
          // Continue with cached data if network unavailable
        }

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

// ============================================
// Refresh Token Action
// ============================================
class RefreshTokenAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      final apiService = ApiService();
      final response = await apiService.oauthRefreshToken();

      if (response.success && response.data != null) {
        final newAccessToken = response.data!['accessToken'];
        final newRefreshToken = response.data!['refreshToken'];

        return state.copyWith(
          auth: state.auth.copyWith(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          ),
        );
      } else {
        // Refresh failed, force logout
        dispatch(LogoutAction());
        return null;
      }
    } catch (e) {
      dispatch(LogoutAction());
      return null;
    }
  }
}

// ============================================
// Change Password Action
// ============================================
class ChangePasswordAction extends ReduxAction<AppState> {
  final String currentPassword;
  final String newPassword;

  ChangePasswordAction({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  Future<AppState?> reduce() async {
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final response = await apiService.changePassword(
        currentPassword,
        newPassword,
      );

      dispatch(SetAuthLoadingAction(isLoading: false));

      if (!response.success) {
        dispatch(
          SetAuthErrorAction(
            error: response.message ?? 'Failed to change password',
          ),
        );
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger().error('Change password failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// ============================================
// Delete Account Action
// ============================================
class DeleteAccountAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      final apiService = ApiService();
      final response = await apiService.deleteOAuthAccount();

      if (response.success) {
        await StorageHelper.clearUserSession();
        return state.copyWith(auth: const AuthState());
      } else {
        dispatch(
          SetAuthErrorAction(
            error: response.message ?? 'Failed to delete account',
          ),
        );
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger().error('Delete account failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// ============================================
// Get Sessions Action
// ============================================
class GetSessionsAction extends ReduxAction<AppState> {
  final void Function(List<dynamic> sessions)? onSuccess;
  final void Function(String error)? onError;

  GetSessionsAction({this.onSuccess, this.onError});

  @override
  Future<AppState?> reduce() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getOAuthSessions();

      if (response.success && response.data?['sessions'] != null) {
        onSuccess?.call(response.data!['sessions']);
      } else {
        onError?.call(response.message ?? 'Failed to get sessions');
      }
    } catch (e) {
      onError?.call(e.toString());
    }
    return null;
  }
}

// ============================================
// Revoke Session Action
// ============================================
class RevokeSessionAction extends ReduxAction<AppState> {
  final String sessionId;

  RevokeSessionAction({required this.sessionId});

  @override
  Future<AppState?> reduce() async {
    try {
      final apiService = ApiService();
      await apiService.revokeOAuthSession(sessionId);
    } catch (e) {
      AppLogger().error('Failed to revoke session', e, null);
    }
    return null;
  }
}

// ============================================
// Helper Actions
// ============================================
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

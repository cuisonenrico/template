import 'package:async_redux/async_redux.dart';
import '../../../core/store/app_state.dart';
import '../../../core/store/substates/auth_state.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/constants/app_constants.dart';
import '../models/auth_models.dart' as auth_models;

// Login Action with Firebase
class LoginAction extends ReduxAction<AppState> {
  final String email;
  final String password;

  LoginAction({required this.email, required this.password});

  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      // Sign in with Firebase
      final firebaseResult = await FirebaseAuthService()
          .signInWithEmailPassword(email: email, password: password);

      if (!firebaseResult.success) {
        dispatch(
          SetAuthErrorAction(
            error: firebaseResult.errorMessage ?? 'Login failed',
          ),
        );
        return null;
      }

      // Get Firebase ID token for backend authentication
      final idToken = await FirebaseAuthService().getIdToken();

      if (idToken == null) {
        dispatch(
          SetAuthErrorAction(error: 'Failed to get authentication token'),
        );
        return null;
      }

      // Optionally: Authenticate with your backend API
      // This syncs Firebase user with your backend
      final apiService = ApiService();
      final response = await apiService.post(AppConstants.loginEndpoint, {
        'firebase_token': idToken,
        'email': email,
      });

      auth_models.User user;
      String? backendAccessToken;
      String? backendRefreshToken;

      if (response.success && response.data != null) {
        // Use backend user data if available
        final authResponse = auth_models.AuthResponse.fromJson(response.data!);
        user = authResponse.user;
        backendAccessToken = authResponse.accessToken;
        backendRefreshToken = authResponse.refreshToken;
      } else {
        // Fallback to Firebase user data
        user = auth_models.User(
          id: firebaseResult.userId ?? '',
          email: firebaseResult.email ?? email,
          name: firebaseResult.displayName,
          avatar: firebaseResult.photoUrl,
        );
      }

      // Store tokens and user data
      await StorageHelper.saveAccessToken(backendAccessToken ?? idToken);
      if (backendRefreshToken != null) {
        await StorageHelper.saveRefreshToken(backendRefreshToken);
      }
      await StorageHelper.saveUserData(user.toJson());
      await StorageHelper.setLoggedIn(true);

      logger.info('User logged in successfully', {
        'userId': user.id,
        'email': user.email,
      });

      // Update state
      return state.copyWith(
        auth: state.auth.copyWith(
          isLoggedIn: true,
          isLoading: false,
          user: user,
          accessToken: backendAccessToken ?? idToken,
          refreshToken: backendRefreshToken,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger().error('Login failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// Google Sign In Action
class GoogleSignInAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      // Sign in with Google
      final firebaseResult = await FirebaseAuthService().signInWithGoogle();

      if (!firebaseResult.success) {
        dispatch(
          SetAuthErrorAction(
            error: firebaseResult.errorMessage ?? 'Google sign in failed',
          ),
        );
        return null;
      }

      // Get Firebase ID token
      final idToken = await FirebaseAuthService().getIdToken();

      if (idToken == null) {
        dispatch(
          SetAuthErrorAction(error: 'Failed to get authentication token'),
        );
        return null;
      }

      // Optionally: Sync with your backend
      final apiService = ApiService();
      final response = await apiService.post(AppConstants.loginEndpoint, {
        'firebase_token': idToken,
        'email': firebaseResult.email,
        'provider': 'google',
      });

      auth_models.User user;
      String? backendAccessToken;
      String? backendRefreshToken;

      if (response.success && response.data != null) {
        final authResponse = auth_models.AuthResponse.fromJson(response.data!);
        user = authResponse.user;
        backendAccessToken = authResponse.accessToken;
        backendRefreshToken = authResponse.refreshToken;
      } else {
        // Fallback to Firebase user data
        user = auth_models.User(
          id: firebaseResult.userId ?? '',
          email: firebaseResult.email ?? '',
          name: firebaseResult.displayName,
          avatar: firebaseResult.photoUrl,
        );
      }

      // Store tokens and user data
      await StorageHelper.saveAccessToken(backendAccessToken ?? idToken);
      if (backendRefreshToken != null) {
        await StorageHelper.saveRefreshToken(backendRefreshToken);
      }
      await StorageHelper.saveUserData(user.toJson());
      await StorageHelper.setLoggedIn(true);

      logger.info('User signed in with Google', {
        'userId': user.id,
        'email': user.email,
      });

      // Update state
      return state.copyWith(
        auth: state.auth.copyWith(
          isLoggedIn: true,
          isLoading: false,
          user: user,
          accessToken: backendAccessToken ?? idToken,
          refreshToken: backendRefreshToken,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger().error('Google sign in failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// Register Action with Firebase
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
      // Sign up with Firebase
      final firebaseResult = await FirebaseAuthService()
          .signUpWithEmailPassword(
            email: email,
            password: password,
            displayName: name,
          );

      if (!firebaseResult.success) {
        dispatch(
          SetAuthErrorAction(
            error: firebaseResult.errorMessage ?? 'Registration failed',
          ),
        );
        return null;
      }

      // Get Firebase ID token
      final idToken = await FirebaseAuthService().getIdToken();

      if (idToken == null) {
        dispatch(
          SetAuthErrorAction(error: 'Failed to get authentication token'),
        );
        return null;
      }

      // Optionally: Register with your backend
      final apiService = ApiService();
      final response = await apiService.post(AppConstants.registerEndpoint, {
        'firebase_token': idToken,
        'email': email,
        'name': name,
      });

      auth_models.User user;
      String? backendAccessToken;
      String? backendRefreshToken;

      if (response.success && response.data != null) {
        final authResponse = auth_models.AuthResponse.fromJson(response.data!);
        user = authResponse.user;
        backendAccessToken = authResponse.accessToken;
        backendRefreshToken = authResponse.refreshToken;
      } else {
        user = auth_models.User(
          id: firebaseResult.userId ?? '',
          email: firebaseResult.email ?? email,
          name: firebaseResult.displayName ?? name,
          avatar: firebaseResult.photoUrl,
        );
      }

      // Store tokens and user data
      await StorageHelper.saveAccessToken(backendAccessToken ?? idToken);
      if (backendRefreshToken != null) {
        await StorageHelper.saveRefreshToken(backendRefreshToken);
      }
      await StorageHelper.saveUserData(user.toJson());
      await StorageHelper.setLoggedIn(true);

      logger.info('User registered successfully', {
        'userId': user.id,
        'email': user.email,
      });

      // Update state
      return state.copyWith(
        auth: state.auth.copyWith(
          isLoggedIn: true,
          isLoading: false,
          user: user,
          accessToken: backendAccessToken ?? idToken,
          refreshToken: backendRefreshToken,
          error: null,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger().error('Registration failed', e, stackTrace);
      dispatch(SetAuthErrorAction(error: e.toString()));
      return null;
    }
  }
}

// Logout Action with Firebase
class LogoutAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    final logger = AppLogger();
    dispatch(SetAuthLoadingAction(isLoading: true));

    try {
      // Logout from Firebase
      await FirebaseAuthService().signOut();

      // Optionally: Logout from backend
      final apiService = ApiService();
      await apiService.post(
        AppConstants.logoutEndpoint,
        {},
        requiresAuth: true,
      );

      logger.info('User logged out');
    } catch (e, stackTrace) {
      logger.error('Logout error', e, stackTrace);
      // Continue with local logout even if Firebase/server logout fails
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

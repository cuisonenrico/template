import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:template/core/constants/app_constants.dart';

import '../config/app_flavor.dart';
import '../utils/app_logger.dart';
import '../utils/storage_helper.dart';
import 'firebase_auth_service.dart';

/// API Service for communicating with the backend
///
/// Supports two authentication modes:
/// 1. **Firebase Auth** (default for be-template): Uses Firebase ID tokens
/// 2. **Endpoint Auth**: Uses stored JWT tokens from login endpoint
///
/// To use Firebase Auth:
///   - Import and use FirebaseAuthService for login
///   - Tokens are automatically fetched from Firebase
///
/// To use Endpoint Auth (without Firebase):
///   - Set `ApiService().useFirebaseAuth = false`
///   - Call login endpoint and store token via StorageHelper.setAccessToken()
///   - Tokens are read from StorageHelper
///
/// Backend API docs available at: {baseUrl}/api/docs
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final _logger = AppLogger();

  /// Toggle between Firebase Auth and Endpoint Auth
  /// Set to false if using a backend with its own auth endpoints
  bool useFirebaseAuth = false;

  /// Get headers for API requests
  /// Automatically chooses between Firebase token or stored token
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      String? token;

      if (useFirebaseAuth) {
        // Try to get Firebase ID token dynamically
        try {
          // Dynamic import to avoid hard dependency
          final firebaseAuth = await _getFirebaseToken();
          token = firebaseAuth;
        } catch (e) {
          _logger.warning('Firebase Auth not available, using stored token');
        }
      }

      // Fallback or primary: use stored token
      token ??= await StorageHelper.getAccessToken();

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Get Firebase ID token if available
  /// Returns null if Firebase is not configured or user not signed in
  Future<String?> _getFirebaseToken() async {
    try {
      final firebaseAuthService = FirebaseAuthService();
      return await firebaseAuthService.getIdToken();
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // Auth Helper Methods (for endpoint-based auth)
  // ============================================

  /// Login with email/password (for backends with their own auth)
  /// Stores the returned tokens automatically
  Future<ApiResponse> login(String email, String password) async {
    final response = await post(AppConstants.loginEndpoint, {
      'email': email,
      'password': password,
    });

    if (response.success && response.data != null) {
      // Store tokens from response
      final accessToken =
          response.data!['accessToken'] ??
          response.data!['access_token'] ??
          response.data!['token'];
      final refreshToken =
          response.data!['refreshToken'] ?? response.data!['refresh_token'];

      if (accessToken != null) {
        await StorageHelper.saveAccessToken(accessToken);
      }
      if (refreshToken != null) {
        await StorageHelper.saveRefreshToken(refreshToken);
      }
    }

    return response;
  }

  /// Register with email/password (for backends with their own auth)
  Future<ApiResponse> register(
    String email,
    String password, {
    String? name,
  }) async {
    final data = {'email': email, 'password': password};
    if (name != null) data['name'] = name;

    return post(AppConstants.registerEndpoint, data);
  }

  /// Refresh access token using stored refresh token
  Future<ApiResponse> refreshToken() async {
    final refreshToken = await StorageHelper.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse(success: false, message: 'No refresh token available');
    }

    final response = await post(AppConstants.refreshTokenEndpoint, {
      'refreshToken': refreshToken,
    });

    if (response.success && response.data != null) {
      final newAccessToken =
          response.data!['accessToken'] ??
          response.data!['access_token'] ??
          response.data!['token'];
      if (newAccessToken != null) {
        await StorageHelper.saveAccessToken(newAccessToken);
      }
    }

    return response;
  }

  /// Logout and clear stored tokens
  Future<void> logout() async {
    try {
      await post(AppConstants.logoutEndpoint, {}, requiresAuth: true);
    } catch (e) {
      // Ignore logout endpoint errors
    }
    await StorageHelper.clearUserSession();
  }

  // ============================================
  // Backend API Helper Methods (cuisonenrico/be-template)
  // ============================================

  /// Health check - verify backend is running
  Future<ApiResponse> healthCheck() async {
    return get(AppConstants.healthEndpoint);
  }

  /// Get current user profile from backend
  Future<ApiResponse> getCurrentUser() async {
    return get(AppConstants.currentUserEndpoint, requiresAuth: true);
  }

  /// Update current user profile
  Future<ApiResponse> updateCurrentUser(Map<String, dynamic> data) async {
    return put(AppConstants.currentUserEndpoint, data, requiresAuth: true);
  }

  /// Delete current user account
  Future<ApiResponse> deleteCurrentUser() async {
    return delete(AppConstants.currentUserEndpoint, requiresAuth: true);
  }

  /// Revoke all refresh tokens (force sign out everywhere)
  Future<ApiResponse> revokeTokens() async {
    return post(AppConstants.revokeTokensEndpoint, {}, requiresAuth: true);
  }

  /// Verify a Firebase token with the backend
  Future<ApiResponse> verifyToken(String token) async {
    return post(AppConstants.verifyTokenEndpoint, {'token': token});
  }

  // ============================================
  // OAuth API Helper Methods (cuisonenrico/be-template)
  // Independent auth system - no Firebase required
  // ============================================

  /// Get available OAuth providers (e.g., ['google'])
  Future<ApiResponse> getOAuthProviders() async {
    return get(AppConstants.oauthProvidersEndpoint);
  }

  /// Get OAuth authorization URL for a provider
  /// Use this for mobile apps to open in browser/webview
  Future<ApiResponse> getOAuthUrl(String provider, {String? state}) async {
    var endpoint = '${AppConstants.oauthAuthorizeUrlEndpoint}/$provider/url';
    if (state != null) {
      endpoint += '?state=$state';
    }
    return get(endpoint);
  }

  /// Exchange OAuth authorization code for tokens
  /// Call this after receiving the callback from OAuth provider
  Future<ApiResponse> oauthCallback(String provider, String code) async {
    final response = await get(
      '${AppConstants.oauthCallbackEndpoint}/$provider?code=$code',
    );

    if (response.success && response.data != null) {
      await _storeTokensFromResponse(response.data!);
    }

    return response;
  }

  /// OAuth login with email/password
  Future<ApiResponse> oauthLogin(String email, String password) async {
    final response = await post(AppConstants.oauthLoginEndpoint, {
      'email': email,
      'password': password,
    });

    if (response.success && response.data != null) {
      await _storeTokensFromResponse(response.data!);
    }

    return response;
  }

  /// OAuth register with email/password
  Future<ApiResponse> oauthRegister(
    String email,
    String password, {
    String? name,
  }) async {
    final data = <String, dynamic>{'email': email, 'password': password};
    if (name != null) data['name'] = name;

    final response = await post(AppConstants.oauthRegisterEndpoint, data);

    if (response.success && response.data != null) {
      await _storeTokensFromResponse(response.data!);
    }

    return response;
  }

  /// Refresh OAuth tokens
  Future<ApiResponse> oauthRefreshToken() async {
    final refreshToken = await StorageHelper.getRefreshToken();
    if (refreshToken == null) {
      return ApiResponse(success: false, message: 'No refresh token available');
    }

    final response = await post(AppConstants.oauthRefreshEndpoint, {
      'refreshToken': refreshToken,
    });

    if (response.success && response.data != null) {
      await _storeTokensFromResponse(response.data!);
    }

    return response;
  }

  /// OAuth logout (single session)
  Future<ApiResponse> oauthLogout() async {
    final refreshToken = await StorageHelper.getRefreshToken();

    final response = await post(
      AppConstants.oauthLogoutEndpoint,
      refreshToken != null ? {'refreshToken': refreshToken} : {},
      requiresAuth: true,
    );

    await StorageHelper.clearUserSession();
    return response;
  }

  /// OAuth logout from all devices
  Future<ApiResponse> oauthLogoutAll() async {
    final response = await post(
      AppConstants.oauthLogoutAllEndpoint,
      {},
      requiresAuth: true,
    );

    await StorageHelper.clearUserSession();
    return response;
  }

  /// Get OAuth user profile with linked accounts
  Future<ApiResponse> getOAuthProfile() async {
    return get(AppConstants.oauthMeEndpoint, requiresAuth: true);
  }

  /// Get active OAuth sessions
  Future<ApiResponse> getOAuthSessions() async {
    return get(AppConstants.oauthSessionsEndpoint, requiresAuth: true);
  }

  /// Revoke a specific OAuth session
  Future<ApiResponse> revokeOAuthSession(String sessionId) async {
    return delete(
      '${AppConstants.oauthRevokeSessionEndpoint}/$sessionId',
      requiresAuth: true,
    );
  }

  /// Link additional OAuth provider to account
  /// Returns the URL to redirect user to for OAuth flow
  Future<ApiResponse> getLinkAccountUrl(String provider) async {
    return get(
      '${AppConstants.oauthLinkAccountEndpoint}/$provider',
      requiresAuth: true,
    );
  }

  /// Unlink OAuth provider from account
  Future<ApiResponse> unlinkAccount(String provider) async {
    return delete(
      '${AppConstants.oauthUnlinkAccountEndpoint}/$provider',
      requiresAuth: true,
    );
  }

  /// Change OAuth account password
  Future<ApiResponse> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return post(AppConstants.oauthChangePasswordEndpoint, {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    }, requiresAuth: true);
  }

  /// Delete OAuth account permanently
  Future<ApiResponse> deleteOAuthAccount() async {
    final response = await delete(
      AppConstants.oauthDeleteAccountEndpoint,
      requiresAuth: true,
    );
    if (response.success) {
      await StorageHelper.clearUserSession();
    }
    return response;
  }

  /// Helper to store tokens from OAuth responses
  Future<void> _storeTokensFromResponse(Map<String, dynamic> data) async {
    final accessToken =
        data['accessToken'] ?? data['access_token'] ?? data['token'];
    final refreshToken = data['refreshToken'] ?? data['refresh_token'];

    if (accessToken != null) {
      await StorageHelper.saveAccessToken(accessToken);
    }
    if (refreshToken != null) {
      await StorageHelper.saveRefreshToken(refreshToken);
    }
  }

  /// Attempts to refresh the access token
  /// Returns true if successful, false otherwise
  bool _isRefreshing = false;
  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final response = await oauthRefreshToken();
      _isRefreshing = false;
      return response.success;
    } catch (e) {
      _isRefreshing = false;
      _logger.warning('Token refresh failed: $e');
      return false;
    }
  }

  // ============================================
  // Generic HTTP Methods
  // ============================================

  Future<ApiResponse> get(
    String endpoint, {
    bool requiresAuth = false,
    bool retryOnUnauthorized = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = '${AppFlavor.current.apiBaseUrl}$endpoint';

    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      _logger.apiRequest('GET', url);

      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(milliseconds: 30000));

      stopwatch.stop();

      // Handle 401 with automatic token refresh
      if (response.statusCode == 401 && requiresAuth && retryOnUnauthorized) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return get(endpoint, requiresAuth: true, retryOnUnauthorized: false);
        }
      }

      final result = _handleResponse(response);

      _logger.apiResponse(
        'GET',
        url,
        response.statusCode,
        result.data,
        duration: stopwatch.elapsed,
      );

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.error('GET $url failed', e, stackTrace);
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  Future<ApiResponse> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
    bool retryOnUnauthorized = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = '${AppFlavor.current.apiBaseUrl}$endpoint';

    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      _logger.apiRequest('POST', url, data: data);

      final response = await _client
          .post(Uri.parse(url), headers: headers, body: jsonEncode(data))
          .timeout(const Duration(milliseconds: 30000));

      stopwatch.stop();

      // Handle 401 with automatic token refresh (but not for auth endpoints)
      final isAuthEndpoint =
          endpoint.contains('/oauth/login') ||
          endpoint.contains('/oauth/register') ||
          endpoint.contains('/oauth/refresh');
      if (response.statusCode == 401 &&
          requiresAuth &&
          retryOnUnauthorized &&
          !isAuthEndpoint) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return post(
            endpoint,
            data,
            requiresAuth: true,
            retryOnUnauthorized: false,
          );
        }
      }

      final result = _handleResponse(response);

      _logger.apiResponse(
        'POST',
        url,
        response.statusCode,
        result.data,
        duration: stopwatch.elapsed,
      );

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.error('POST $url failed', e, stackTrace);
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  Future<ApiResponse> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
    bool retryOnUnauthorized = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = '${AppFlavor.current.apiBaseUrl}$endpoint';

    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      _logger.apiRequest('PUT', url, data: data);

      final response = await _client
          .put(Uri.parse(url), headers: headers, body: json.encode(data))
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
          );

      stopwatch.stop();

      // Handle 401 with automatic token refresh
      if (response.statusCode == 401 && requiresAuth && retryOnUnauthorized) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return put(
            endpoint,
            data,
            requiresAuth: true,
            retryOnUnauthorized: false,
          );
        }
      }

      final result = _handleResponse(response);

      _logger.apiResponse(
        'PUT',
        url,
        response.statusCode,
        result.data,
        duration: stopwatch.elapsed,
      );

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.error('PUT $url failed', e, stackTrace);
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    bool requiresAuth = false,
    bool retryOnUnauthorized = true,
  }) async {
    final stopwatch = Stopwatch()..start();
    final url = '${AppFlavor.current.apiBaseUrl}$endpoint';

    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      _logger.apiRequest('DELETE', url);

      final response = await _client
          .delete(Uri.parse(url), headers: headers)
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
          );

      stopwatch.stop();

      // Handle 401 with automatic token refresh
      if (response.statusCode == 401 && requiresAuth && retryOnUnauthorized) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          return delete(
            endpoint,
            requiresAuth: true,
            retryOnUnauthorized: false,
          );
        }
      }

      final result = _handleResponse(response);

      _logger.apiResponse(
        'DELETE',
        url,
        response.statusCode,
        result.data,
        duration: stopwatch.elapsed,
      );

      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _logger.error('DELETE $url failed', e, stackTrace);
      return ApiResponse(success: false, message: _getErrorMessage(e));
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    Map<String, dynamic>? responseData;

    try {
      responseData = json.decode(response.body);
    } catch (e) {
      responseData = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        success: true,
        data: responseData,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse(
        success: false,
        message: responseData?['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
        data: responseData,
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error is HttpException) {
      return 'Server error occurred';
    } else {
      return 'An unexpected error occurred';
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, message: $message, statusCode: $statusCode}';
  }
}

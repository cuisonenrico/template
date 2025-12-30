class AppConstants {
  // API Base URL (configured per environment in app_flavor.dart)
  static const String baseUrl = 'https://be-template-232655288630.europe-west1.run.app';

  // ============================================
  // Backend API Endpoints (cuisonenrico/be-template)
  // ============================================

  // Firebase Auth Endpoints (for Firebase-based auth)
  static const String verifyTokenEndpoint = '/auth/verify';
  static const String firebaseUserEndpoint = '/auth/me';
  static const String profileEndpoint = '/auth/profile';
  static const String revokeTokensEndpoint = '/auth/revoke-tokens';

  // Admin Auth Endpoints (Firebase)
  static const String listUsersEndpoint = '/auth/users';
  static const String getUserByUidEndpoint = '/auth/users'; // + /:uid
  static const String getUserByEmailEndpoint = '/auth/users/email'; // + /:email

  // ============================================
  // OAuth Endpoints (independent auth system)
  // ============================================

  // OAuth Auth Endpoints
  static const String oauthRegisterEndpoint = '/oauth/register';
  static const String oauthLoginEndpoint = '/oauth/login';
  static const String oauthRefreshEndpoint = '/oauth/refresh';
  static const String oauthLogoutEndpoint = '/oauth/logout';
  static const String oauthLogoutAllEndpoint = '/oauth/logout/all';

  // OAuth User Profile
  static const String oauthMeEndpoint = '/oauth/me';
  static const String oauthChangePasswordEndpoint = '/oauth/me/password';
  static const String oauthDeleteAccountEndpoint = '/oauth/me';

  // OAuth Providers
  static const String oauthProvidersEndpoint = '/oauth/providers';
  static const String oauthAuthorizeEndpoint = '/oauth/authorize'; // + /:provider
  static const String oauthAuthorizeUrlEndpoint = '/oauth/authorize'; // + /:provider/url
  static const String oauthCallbackEndpoint = '/oauth/callback'; // + /:provider

  // OAuth Account Linking
  static const String oauthLinkAccountEndpoint = '/oauth/link'; // + /:provider
  static const String oauthUnlinkAccountEndpoint = '/oauth/accounts'; // + /:provider

  // OAuth Sessions
  static const String oauthSessionsEndpoint = '/oauth/sessions';
  static const String oauthRevokeSessionEndpoint = '/oauth/sessions'; // + /:sessionId

  // User Endpoints
  static const String usersEndpoint = '/users';

  // Health Check
  static const String healthEndpoint = '/health';

  // Legacy aliases (point to OAuth endpoints for non-Firebase auth)
  static const String loginEndpoint = '/oauth/login';
  static const String registerEndpoint = '/oauth/register';
  static const String refreshTokenEndpoint = '/oauth/refresh';
  static const String logoutEndpoint = '/oauth/logout';
  static const String currentUserEndpoint = '/oauth/me';
  static const String userProfileEndpoint = '/oauth/me';

  // Route Names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String counterRoute = '/counter';
  static const String profileRoute = '/profile';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  static const String themeModeKey = 'theme_mode';
  static const String firebaseUidKey = 'firebase_uid';

  // App Info
  static const String appName = 'Flutter Template';
  static const String appVersion = '1.0.0';

  // Backend Repository
  static const String backendRepo = 'https://github.com/cuisonenrico/be-template';
  static const String apiDocsPath = '/api/docs';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Validation
  static const int minPasswordLength = 8;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}

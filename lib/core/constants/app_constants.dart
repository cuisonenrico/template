class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://api.yourapp.com';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';
  static const String userProfileEndpoint = '/user/profile';

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

  // App Info
  static const String appName = 'Flutter Template';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Validation
  static const int minPasswordLength = 8;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}

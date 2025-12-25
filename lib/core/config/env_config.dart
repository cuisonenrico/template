class EnvConfig {
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.yourapp.com',
  );

  static const int apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  // App Configuration
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Flutter Template',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // Feature Flags
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  // Environment checks
  static bool get isDevelopment => _env == 'development';
  static bool get isStaging => _env == 'staging';
  static bool get isProduction => _env == 'production';

  // Get current environment name
  static String get environment => _env;
}

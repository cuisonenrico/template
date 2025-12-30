import 'package:flutter/foundation.dart';
import 'package:template/core/constants/app_constants.dart';

enum AppFlavor {
  development,
  staging,
  production;

  static AppFlavor? _current;

  static void setFlavor(AppFlavor flavor) {
    _current = flavor;
  }

  static AppFlavor get current {
    if (_current == null) {
      throw Exception('AppFlavor has not been set! Call AppFlavor.setFlavor() in main()');
    }
    return _current!;
  }

  bool get isDevelopment => this == AppFlavor.development;
  bool get isStaging => this == AppFlavor.staging;
  bool get isProduction => this == AppFlavor.production;

  String get name {
    switch (this) {
      case AppFlavor.development:
        return 'Development';
      case AppFlavor.staging:
        return 'Staging';
      case AppFlavor.production:
        return 'Production';
    }
  }

  String get apiBaseUrl {
    switch (this) {
      case AppFlavor.development:
        return const String.fromEnvironment('API_BASE_URL', defaultValue: AppConstants.baseUrl);
      case AppFlavor.staging:
        return const String.fromEnvironment('API_BASE_URL', defaultValue: AppConstants.baseUrl);
      case AppFlavor.production:
        return const String.fromEnvironment('API_BASE_URL', defaultValue: AppConstants.baseUrl);
    }
  }

  String get appName {
    switch (this) {
      case AppFlavor.development:
        return 'Template Dev';
      case AppFlavor.staging:
        return 'Template Staging';
      case AppFlavor.production:
        return 'Template';
    }
  }

  bool get enableLogging {
    return this != AppFlavor.production;
  }

  bool get enableAnalytics {
    return this == AppFlavor.production;
  }

  void logDebug(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[${name.toUpperCase()}] $message');
    }
  }
}

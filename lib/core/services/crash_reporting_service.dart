import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Abstract crash reporting provider interface
/// Implement this for different services (Crashlytics, Sentry, Bugsnag, etc.)
abstract class CrashReportingProvider {
  /// Initialize the provider
  Future<void> init();

  /// Set user identifier
  Future<void> setUserId(String? userId);

  /// Set custom key-value pairs
  Future<void> setCustomKey(String key, dynamic value);

  /// Set custom keys in bulk
  Future<void> setCustomKeys(Map<String, dynamic> keys);

  /// Log a non-fatal error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  });

  /// Log a message
  Future<void> log(String message);

  /// Enable or disable crash collection
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
}

/// Debug crash reporting that logs to console
class DebugCrashReportingProvider implements CrashReportingProvider {
  @override
  Future<void> init() async {
    AppLogger().debug('[CrashReporting] Initialized (Debug Mode)');
  }

  @override
  Future<void> setUserId(String? userId) async {
    AppLogger().debug('[CrashReporting] Set User ID: $userId');
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    AppLogger().debug('[CrashReporting] Set Key: $key = $value');
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    AppLogger().debug('[CrashReporting] Set Keys: $keys');
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    AppLogger().error(
      '[CrashReporting] ${fatal ? 'FATAL' : 'Non-Fatal'} Error: $reason',
      exception,
      stackTrace,
    );
  }

  @override
  Future<void> log(String message) async {
    AppLogger().debug('[CrashReporting] Log: $message');
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    AppLogger().debug('[CrashReporting] Collection Enabled: $enabled');
  }
}

/// No-op crash reporting (for when disabled)
class NoOpCrashReportingProvider implements CrashReportingProvider {
  @override
  Future<void> init() async {}
  @override
  Future<void> setUserId(String? userId) async {}
  @override
  Future<void> setCustomKey(String key, dynamic value) async {}
  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {}
  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {}
  @override
  Future<void> log(String message) async {}
  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {}
}

/// Central crash reporting service
class CrashReportingService {
  static final CrashReportingService _instance =
      CrashReportingService._internal();
  factory CrashReportingService() => _instance;
  CrashReportingService._internal();

  late CrashReportingProvider _provider;
  bool _initialized = false;

  /// Initialize crash reporting
  ///
  /// Usage in main.dart:
  /// ```dart
  /// await CrashReportingService().init(
  ///   kDebugMode ? DebugCrashReportingProvider() : FirebaseCrashlyticsProvider(),
  /// );
  /// ```
  Future<void> init(CrashReportingProvider provider) async {
    _provider = provider;
    await _provider.init();
    _initialized = true;

    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      recordFlutterError(details);
    };

    // Handle async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, fatal: true);
      return true;
    };
  }

  void _checkInitialized() {
    if (!_initialized) {
      if (kDebugMode) {
        AppLogger().warning('CrashReporting not initialized, using NoOp');
      }
      _provider = NoOpCrashReportingProvider();
      _initialized = true;
    }
  }

  /// Record a Flutter framework error
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    _checkInitialized();
    await _provider.recordError(
      details.exception,
      details.stack,
      reason: details.exceptionAsString(),
      fatal: details.silent != true,
    );
  }

  /// Record an error
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    _checkInitialized();
    await _provider.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Set user ID for error reports
  Future<void> setUserId(String? userId) async {
    _checkInitialized();
    await _provider.setUserId(userId);
  }

  /// Set custom key
  Future<void> setCustomKey(String key, dynamic value) async {
    _checkInitialized();
    await _provider.setCustomKey(key, value);
  }

  /// Set multiple custom keys
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    _checkInitialized();
    await _provider.setCustomKeys(keys);
  }

  /// Log a message (appears in crash reports)
  Future<void> log(String message) async {
    _checkInitialized();
    await _provider.log(message);
  }

  /// Enable or disable collection
  Future<void> setEnabled(bool enabled) async {
    _checkInitialized();
    await _provider.setCrashlyticsCollectionEnabled(enabled);
  }
}

/// Extension for easy error reporting
extension CrashReportingExtension on Object {
  /// Report this error to crash reporting
  Future<void> reportError({
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    await CrashReportingService().recordError(
      this,
      stackTrace ?? StackTrace.current,
      reason: reason,
      fatal: fatal,
    );
  }
}

/* 
============================================
FIREBASE CRASHLYTICS IMPLEMENTATION EXAMPLE
============================================

To use Firebase Crashlytics, add this to your project:

1. Add dependency:
   flutter pub add firebase_crashlytics

2. Create provider:

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseCrashlyticsProvider implements CrashReportingProvider {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  @override
  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (userId != null) {
      await _crashlytics.setUserIdentifier(userId);
    }
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    for (final entry in keys.entries) {
      await _crashlytics.setCustomKey(entry.key, entry.value);
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  @override
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }
}

3. Initialize in main.dart:

await CrashReportingService().init(
  kDebugMode 
    ? DebugCrashReportingProvider() 
    : FirebaseCrashlyticsProvider(),
);

============================================
SENTRY IMPLEMENTATION EXAMPLE
============================================

1. Add dependency:
   flutter pub add sentry_flutter

2. Create provider:

import 'package:sentry_flutter/sentry_flutter.dart';

class SentryProvider implements CrashReportingProvider {
  @override
  Future<void> init() async {
    // Sentry is initialized in main.dart with SentryFlutter.init()
  }

  @override
  Future<void> setUserId(String? userId) async {
    Sentry.configureScope((scope) {
      scope.setUser(userId != null ? SentryUser(id: userId) : null);
    });
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    Sentry.configureScope((scope) {
      scope.setTag(key, value.toString());
    });
  }

  @override
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    Sentry.configureScope((scope) {
      keys.forEach((key, value) {
        scope.setTag(key, value.toString());
      });
    });
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> log(String message) async {
    Sentry.addBreadcrumb(Breadcrumb(message: message));
  }

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    // Sentry doesn't have a direct equivalent
  }
}

3. Initialize in main.dart:

await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
    options.tracesSampleRate = 1.0;
  },
  appRunner: () => runApp(MyApp()),
);

await CrashReportingService().init(SentryProvider());

*/

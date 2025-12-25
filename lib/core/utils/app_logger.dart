import 'package:logger/logger.dart';
import '../config/app_flavor.dart';

/// Centralized logger for the application
/// Provides beautiful, readable logs in debug console
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late final Logger _logger;

  void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      level: AppFlavor.current.isDevelopment ? Level.debug : Level.warning,
    );
  }

  /// Log debug message
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal/critical error
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log API request
  void apiRequest(String method, String url, {Map<String, dynamic>? data}) {
    if (!AppFlavor.current.isDevelopment) return;

    _logger.i(
      '🌐 API Request',
      error: {'method': method, 'url': url, if (data != null) 'body': data},
    );
  }

  /// Log API response
  void apiResponse(
    String method,
    String url,
    int statusCode,
    dynamic data, {
    Duration? duration,
  }) {
    if (!AppFlavor.current.isDevelopment) return;

    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';

    _logger.i(
      '$emoji API Response',
      error: {
        'method': method,
        'url': url,
        'status': statusCode,
        'data': data,
        if (duration != null) 'duration': '${duration.inMilliseconds}ms',
      },
    );
  }

  /// Log database operation
  void database(String operation, String boxName, {dynamic data}) {
    if (!AppFlavor.current.isDevelopment) return;

    _logger.d(
      '💾 Database: $operation',
      error: {'box': boxName, if (data != null) 'data': data},
    );
  }
}

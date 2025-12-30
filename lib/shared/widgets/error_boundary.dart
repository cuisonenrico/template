import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';

/// Global error handler for catching and displaying runtime errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails error, VoidCallback retry)?
  errorBuilder;
  final void Function(Object error, StackTrace stack)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();

  /// Initialize global error handling
  /// Call this in main() before runApp()
  static void init({void Function(Object error, StackTrace stack)? onError}) {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      AppLogger().error(
        'Flutter Error: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
      onError?.call(details.exception, details.stack ?? StackTrace.current);
    };

    // Handle errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger().error('Platform Error: $error', error, stack);
      onError?.call(error, stack);
      return true;
    };

    // Handle async errors
    runZonedGuarded(
      () {
        // App will be wrapped in this zone
      },
      (error, stack) {
        AppLogger().error('Async Error: $error', error, stack);
        onError?.call(error, stack);
      },
    );
  }

  /// Wrap your app with error handling zone
  /// Usage in main.dart:
  /// ```dart
  /// ErrorBoundary.runApp(
  ///   app: MyApp(),
  ///   onError: (error, stack) => reportToSentry(error, stack),
  /// );
  /// ```
  static void runApp({
    required Widget app,
    void Function(Object error, StackTrace stack)? onError,
  }) {
    init(onError: onError);

    runZonedGuarded(() => runApp(app: app), (error, stack) {
      AppLogger().error('Uncaught Error: $error', error, stack);
      onError?.call(error, stack);
    });
  }
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _retry) ??
          _DefaultErrorWidget(error: _error!, onRetry: _retry);
    }

    return widget.child;
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                kDebugMode
                    ? error.exceptionAsString()
                    : 'An unexpected error occurred. Please try again.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that catches errors in its child and displays a fallback UI
class ErrorCatcher extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final void Function(Object error, StackTrace stack)? onError;

  const ErrorCatcher({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorCatcher> createState() => _ErrorCatcherState();
}

class _ErrorCatcherState extends State<ErrorCatcher> {
  Object? _error;

  @override
  void initState() {
    super.initState();
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _retry) ??
          _InlineErrorWidget(error: _error!, onRetry: _retry);
    }

    // Use an ErrorWidget.builder to catch build errors
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stack) {
          _handleError(error, stack);
          return _InlineErrorWidget(error: error, onRetry: _retry);
        }
      },
    );
  }

  void _handleError(Object error, StackTrace stack) {
    AppLogger().error('ErrorCatcher caught error', error, stack);
    widget.onError?.call(error, stack);

    if (mounted) {
      setState(() {
        _error = error;
      });
    }
  }
}

class _InlineErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _InlineErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 8),
          Text(
            'Error loading content',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 4),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

/// Extension to show error dialogs easily
extension ErrorDialog on BuildContext {
  /// Show an error dialog
  Future<void> showErrorDialog({
    required String message,
    String? title,
    String? buttonText,
  }) {
    return showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Show an error snackbar
  void showErrorSnackbar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(this).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(this).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show a success snackbar
  void showSuccessSnackbar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}

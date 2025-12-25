# Logger Documentation

## Overview

The app uses the [logger](https://pub.dev/packages/logger) package for beautiful, readable logs in the debug console. The logger is centralized in `AppLogger` class and provides colorful, emoji-rich logs with proper formatting.

## Features

- ✅ **Colorful logs** with syntax highlighting
- ✅ **Emoji indicators** for quick log type identification
- ✅ **Stack traces** for errors
- ✅ **API request/response logging** with timing
- ✅ **Database operation logging**
- ✅ **Environment-aware** (only logs in development mode)
- ✅ **Pretty printed** JSON and objects

## Log Levels

| Level | Method | Emoji | Use Case |
|-------|--------|-------|----------|
| Debug | `debug()` | 🐛 | Detailed debugging information |
| Info | `info()` | 💡 | General informational messages |
| Warning | `warning()` | ⚠️ | Warning messages |
| Error | `error()` | ❌ | Error messages with stack traces |
| Fatal | `fatal()` | 💀 | Critical errors |

## Usage

### Basic Logging

```dart
import '../core/utils/app_logger.dart';

final _logger = AppLogger();

// Debug message
_logger.debug('User clicked button');

// Info message
_logger.info('Feature initialized');

// Warning
_logger.warning('Cache is getting full');

// Error with exception
try {
  // some code
} catch (e, stackTrace) {
  _logger.error('Failed to process data', e, stackTrace);
}
```

### API Request/Response Logging

The `ApiService` automatically logs all HTTP requests and responses with timing:

```dart
// Logs:
// 🌐 API Request
// {
//   method: 'POST',
//   url: 'https://api.example.com/users',
//   body: { name: 'John', email: 'john@example.com' }
// }
//
// ✅ API Response (or ❌ for errors)
// {
//   method: 'POST',
//   url: 'https://api.example.com/users',
//   status: 200,
//   data: { id: 1, name: 'John' },
//   duration: '342ms'
// }
```

### Database Operation Logging

The `HiveService` logs all database operations:

```dart
// Logs:
// 💾 Database: Opening box
// { box: 'users', items: 15 }
//
// 💾 Database: Box cleared
// { box: 'cache', items_removed: 42 }
```

### Custom Structured Logging

You can pass structured data (maps) as error parameter for better formatting:

```dart
_logger.info(
  'User login',
  {
    'userId': user.id,
    'email': user.email,
    'loginTime': DateTime.now().toString(),
  },
);
```

## Implementation Examples

### In Redux Actions

```dart
import '../../core/utils/app_logger.dart';

class FetchUsersAction extends ReduxAction<AppState> {
  final _logger = AppLogger();

  @override
  Future<AppState?> reduce() async {
    _logger.debug('Fetching users from API');
    
    try {
      final response = await ApiService().get('/users');
      
      if (response.success) {
        _logger.info('Users fetched successfully', {'count': response.data?.length});
        // process data
      }
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch users', e, stackTrace);
    }
    
    return null;
  }
}
```

### In Custom Services

```dart
import '../utils/app_logger.dart';

class CacheService {
  final _logger = AppLogger();

  Future<void> clearCache() async {
    _logger.debug('Clearing cache');
    
    try {
      await HiveService().clearBox('cache');
      _logger.info('Cache cleared successfully');
    } catch (e, stackTrace) {
      _logger.error('Failed to clear cache', e, stackTrace);
    }
  }
}
```

### In Business Logic

```dart
class PaymentProcessor {
  final _logger = AppLogger();

  Future<bool> processPayment(Payment payment) async {
    _logger.info(
      'Processing payment',
      {
        'amount': payment.amount,
        'currency': payment.currency,
        'method': payment.method,
      },
    );
    
    try {
      // process payment
      _logger.info('Payment processed successfully', {'transactionId': txId});
      return true;
    } catch (e, stackTrace) {
      _logger.error('Payment processing failed', e, stackTrace);
      return false;
    }
  }
}
```

## Log Output Examples

### Debug Console Output

```
💡 INFO | 2024-01-15 14:23:45 | 🚀 App started
  {
    flavor: development,
    apiBaseUrl: https://dev-api.example.com,
    environment: development
  }

🌐 INFO | 2024-01-15 14:23:47 | 🌐 API Request
  {
    method: POST,
    url: https://dev-api.example.com/auth/login,
    body: {
      email: user@example.com,
      password: ********
    }
  }

✅ INFO | 2024-01-15 14:23:48 | ✅ API Response
  {
    method: POST,
    url: https://dev-api.example.com/auth/login,
    status: 200,
    data: {
      token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...,
      user: { id: 1, name: John Doe }
    },
    duration: 342ms
  }

💾 DEBUG | 2024-01-15 14:23:48 | 💾 Database: Box cleared
  {
    box: auth_cache,
    items_removed: 1
  }
```

## Configuration

The logger is configured in `lib/core/utils/app_logger.dart`:

```dart
Logger(
  printer: PrettyPrinter(
    methodCount: 2,        // Method calls shown
    errorMethodCount: 8,   // Method calls for errors
    lineLength: 120,       // Output width
    colors: true,          // Colored output
    printEmojis: true,     // Show emojis
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  level: AppFlavor.current.isDevelopment ? Level.debug : Level.warning,
);
```

## Production Behavior

In production builds (staging/production flavors), the logger:
- Only logs warnings and errors
- Skips API request/response logging
- Skips database operation logging
- Reduces performance overhead

This is automatically configured based on `AppFlavor.current.isDevelopment`.

## Best Practices

1. **Use appropriate log levels**
   - Debug: Detailed debugging information
   - Info: Important application events
   - Warning: Potential issues that don't break functionality
   - Error: Actual errors that should be investigated

2. **Include context in logs**
   ```dart
   // ❌ Bad
   _logger.error('Failed');
   
   // ✅ Good
   _logger.error('Failed to fetch user profile', e, stackTrace);
   ```

3. **Use structured data for complex logs**
   ```dart
   // ✅ Good - Easy to read and search
   _logger.info('Order placed', {
     'orderId': order.id,
     'amount': order.total,
     'items': order.items.length,
   });
   ```

4. **Don't log sensitive information**
   ```dart
   // ❌ Bad - Exposes password
   _logger.debug('Login attempt', {'password': password});
   
   // ✅ Good
   _logger.debug('Login attempt', {'email': email});
   ```

5. **Log errors with stack traces**
   ```dart
   try {
     // code
   } catch (e, stackTrace) {
     _logger.error('Operation failed', e, stackTrace); // Always pass stackTrace
   }
   ```

## Integration Points

The logger is integrated into:
- ✅ `ApiService` - All HTTP requests/responses
- ✅ `HiveService` - All database operations
- ✅ `main_common.dart` - App initialization
- ✅ Ready for use in all Redux actions
- ✅ Ready for use in custom services

## Troubleshooting

### Logs not appearing

1. Check flavor configuration - logs are limited in production
2. Ensure logger is initialized in `main_common.dart`
3. Check VS Code Debug Console (not terminal)

### Too many logs

Adjust the log level in `app_logger.dart`:

```dart
level: Level.warning, // Only show warnings and errors
```

### Logs are truncated

Increase line length in `app_logger.dart`:

```dart
lineLength: 200, // Wider output
```

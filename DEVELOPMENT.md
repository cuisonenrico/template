# Development Guide

## Quick Start

### Initial Setup (First Time Only)

Run the automated setup script:

```bash
./scripts/setup.sh
```

This will:
- Install dependencies
- Set up your app name and bundle ID
- Configure API base URL
- Create environment files
- Run code generation
- Install Mason CLI (optional)

### Manual Setup (Alternative)

If you prefer manual setup:

```bash
# 1. Install dependencies
flutter pub get

# 2. Rename your app
dart run rename setAppName --targets ios,android,web --value "Your App Name"
dart run rename setBundleId --targets ios,android --value "com.yourcompany.app"

# 3. Update API URL in lib/core/constants/app_constants.dart

# 4. Run code generation
dart run build_runner build --delete-conflicting-outputs
```

## Daily Development

### Running the App

```bash
# Development environment (default)
./scripts/run.sh development

# Staging environment
./scripts/run.sh staging

# Production environment
./scripts/run.sh production
```

Or use Flutter directly:

```bash
flutter run
flutter run --dart-define-from-file=.env.development
```

### Building the App

```bash
# Build APK for production
./scripts/build.sh production apk

# Build iOS for staging
./scripts/build.sh staging ios

# Build web for development
./scripts/build.sh development web
```

Supported platforms: `apk`, `appbundle`, `ios`, `web`, `windows`, `macos`, `linux`

## Feature Development

### Creating a New Feature

```bash
mason make feature --name profile
```

This automatically:
- ✅ Creates MVC structure (models, controllers, views)
- ✅ Adds route to `app_router.dart`
- ✅ Creates state file in `lib/core/store/substates/`
- ✅ Updates `AppState` to include new feature state
- ✅ Adds API endpoints to `app_constants.dart` (if using API)
- ✅ Generates test file
- ✅ Runs `build_runner` automatically

After generation, navigate with:
```dart
context.goToProfile();
context.pushProfile();
```

### Working with State

All state is managed through Async Redux:

```dart
// Dispatch an action
context.dispatch(FetchProfileAction());
store.dispatch(UpdateProfileAction(profile));

// Access state in widgets
StoreConnector<AppState, ProfileVm>(
  vm: () => ProfileVmFactory(),
  builder: (context, vm) => ProfileScreen(...),
);
```

### Code Generation

After modifying Freezed models:

```bash
# One-time generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
dart run build_runner watch --delete-conflicting-outputs
```

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/profile_test.dart

# With coverage
flutter test --coverage
```

### Test Structure

Each feature automatically gets a test file with:
- Action tests (state updates)
- Model tests (serialization)
- Widget tests (coming soon)

Example:
```dart
test('FetchProfileAction updates state', () async {
  await store.dispatchAndWait(FetchProfileAction());
  expect(store.state.profile.isLoading, false);
});
```

## Environment Management

### Environment Files

- `.env.development` - Local development
- `.env.staging` - Staging/QA environment
- `.env.production` - Production release

### Adding Environment Variables

1. Add to `.env.example`:
```bash
NEW_API_KEY=your_key_here
```

2. Add to `lib/core/config/env_config.dart`:
```dart
static const String newApiKey = String.fromEnvironment(
  'NEW_API_KEY',
  defaultValue: 'default_value',
);
```

3. Copy to all environment files and update values

## Code Organization

### Feature Structure

```
lib/features/profile/
├── controllers/
│   └── profile_actions.dart     # Business logic (Redux actions)
├── models/
│   └── profile_models.dart      # Data models (Freezed)
└── views/
    ├── profile_screen.dart      # UI
    ├── profile_connector.dart   # StoreConnector
    └── profile_vm.dart          # ViewModel factory
```

### Import Conventions

```dart
// ✅ Good: Relative imports within feature
import '../models/profile_models.dart';

// ✅ Good: Absolute imports for cross-feature
import 'package:template/core/services/api_service.dart';

// ❌ Bad: Absolute imports within same feature
import 'package:template/features/profile/models/profile_models.dart';
```

## Common Tasks

### Adding a New API Endpoint

Mason does this automatically, but if needed manually:

1. Add to `app_constants.dart`:
```dart
static const String profileEndpoint = '/profile';
```

2. Use in actions:
```dart
final response = await apiService.get(
  AppConstants.profileEndpoint,
  requiresAuth: true,
);
```

### Adding a New Route

Mason does this automatically, but if needed manually:

1. Import connector in `app_router.dart`
2. Add GoRoute
3. Add extension methods

### Customizing Theme

Edit `lib/core/constants/app_theme.dart`:

```dart
static const Color seedColor = Color(0xFF6750A4); // Your brand color
static const double space12 = 12.0; // Custom spacing
```

## Troubleshooting

### Build Runner Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### State Not Updating

- Check if you're dispatching actions correctly
- Verify `StoreConnector` vm factory
- Ensure `copyWith` is used in reducers

### Route Not Found

- Check `app_router.dart` for route definition
- Verify connector import
- Ensure extension methods exist

### Environment Variables Not Working

- Check `.env.*` file exists
- Verify `env_config.dart` has the variable
- Run with: `flutter run --dart-define-from-file=.env.development`

## Performance Tips

1. Use `const` constructors where possible
2. Avoid rebuilding widgets unnecessarily
3. Use `StoreConnector` efficiently (don't pass whole state)
4. Keep ViewModels focused and minimal
5. Use `distinct` in `StoreConnector` for expensive builds

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Run tests
  run: flutter test

- name: Build APK
  run: ./scripts/build.sh production apk
```

### Environment Secrets

Store in CI/CD secrets:
- `API_BASE_URL_PROD`
- `API_BASE_URL_STAGING`
- Firebase keys
- Signing keys

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Async Redux Documentation](https://pub.dev/packages/async_redux)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Mason Documentation](https://pub.dev/packages/mason)

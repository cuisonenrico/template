# Flutter Template

A **production-ready Flutter template** with OAuth authentication, Async Redux state management, GoRouter navigation, and comprehensive utilities for rapid app development.

## ✨ Features

### Core
- ✅ **OAuth Authentication** - Email/password + Google OAuth (Firebase optional)
- ✅ **Async Redux** - Predictable state management with actions and reducers
- ✅ **GoRouter** - Declarative navigation with auth guards
- ✅ **MVC Architecture** - Feature-based organization with clear separation
- ✅ **Material Design 3** - Modern theming with light/dark/system modes

### Data & Storage
- ✅ **Hive Database** - Offline-first local storage with type-safe models
- ✅ **API Service** - HTTP client with automatic token refresh on 401
- ✅ **SharedPreferences** - StorageHelper wrapper for simple key-value storage

### Utilities
- ✅ **Form Validators** - Email, password, phone, credit card, and more
- ✅ **Pagination** - Infinite scroll with state management
- ✅ **Pull-to-Refresh** - RefreshableList widget with loading/error states
- ✅ **Image Handling** - Picker, compression, cached network images
- ✅ **Connectivity** - Network status monitoring with offline banner
- ✅ **Error Boundary** - Global error handling with retry UI
- ✅ **Notifications** - Local + push notification ready
- ✅ **Localization** - i18n with ARB files (English, Spanish included)
- ✅ **Analytics** - Pluggable analytics abstraction
- ✅ **Crash Reporting** - Crashlytics/Sentry ready

### Developer Experience
- ✅ **Mason Bricks** - Automated feature scaffolding
- ✅ **Build Flavors** - Development, staging, production environments
- ✅ **Logging** - Pretty console logs with AppLogger
- ✅ **Unit Tests** - Tests for actions, validators, pagination

## 🚀 Quick Start

### 1. Setup (Recommended)

```bash
# Clone and enter the project
git clone <repository-url>
cd template

# Run interactive setup
./scripts/setup.sh
```

The setup script will:
- Configure app name and bundle ID
- Set up API base URL
- Create environment files
- Run code generation

### 2. Manual Setup

```bash
# Get dependencies
flutter pub get

# Rename your app
dart run rename setAppName --targets ios,android,web --value "Your App"
dart run rename setBundleId --targets ios,android --value "com.company.app"

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the App

```bash
# Run with development config
./scripts/run.sh development

# Or standard run
flutter run
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # Environment & flavor configuration
│   ├── constants/       # Theme, API constants
│   ├── router/          # GoRouter configuration
│   ├── services/        # API, Hive, Analytics, Connectivity, etc.
│   ├── store/           # Redux store & substates
│   └── utils/           # Validators, pagination, logging, storage
├── features/
│   ├── auth/            # Login, register, OAuth
│   ├── counter/         # Demo feature
│   └── theme/           # Theme switching
├── l10n/                # Localization ARB files
└── shared/
    └── widgets/         # Reusable components
```

## 🔐 Authentication

This template uses **OAuth-first authentication** (no Firebase required by default).

### Email/Password Login
```dart
await context.dispatch(LoginAction(
  email: 'user@example.com',
  password: 'password123',
));
```

### Google OAuth
```dart
await context.dispatch(GetGoogleAuthUrlAction(
  onSuccess: (url) => launchUrl(Uri.parse(url)),
  onError: (error) => showError(error),
));
```

### Enable Firebase Auth (Optional)
In `main_common.dart`, set:
```dart
const bool useFirebaseAuth = true;
```

📖 See [AUTH.md](AUTH.md) for complete documentation.

## 🧩 Adding New Features

### Using Mason (Recommended)

```bash
mason make feature --name your_feature
```

This automatically creates:
- MVC structure (models, controllers, views)
- Hive integration with offline caching
- Route registration
- Redux state & actions
- API endpoints
- Unit tests

### Manual Creation
See [DEVELOPMENT.md](DEVELOPMENT.md) for step-by-step guide.

## 📚 Documentation

| File | Description |
|------|-------------|
| [AUTH.md](AUTH.md) | Authentication flows, actions, endpoints |
| [DEVELOPMENT.md](DEVELOPMENT.md) | Development workflow, adding features |
| [FLAVORS.md](FLAVORS.md) | Build flavors & environment configuration |
| [NOTIFICATIONS.md](NOTIFICATIONS.md) | Push & local notifications setup |
| [LOGGER.md](LOGGER.md) | Logging utilities |
| [FIREBASE_AUTH_SETUP.md](FIREBASE_AUTH_SETUP.md) | Firebase configuration (optional) |

## 🛠️ Common Commands

```bash
# Run with environment
./scripts/run.sh development
./scripts/run.sh production

# Build
./scripts/build.sh production apk
./scripts/build.sh staging ios

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Tests
flutter test

# Analyze
flutter analyze
```

## 🎨 Utilities Usage

### Form Validation
```dart
TextFormField(
  validator: Validators.compose([
    Validators.required('Email is required'),
    Validators.email(),
  ]),
)
```

### Pagination
```dart
PaginatedListView<Item>(
  state: paginatedState,
  onLoadMore: () => dispatch(LoadMoreAction()),
  onRefresh: () async => dispatch(RefreshAction()),
  itemBuilder: (context, item, index) => ItemTile(item),
)
```

### Connectivity Banner
```dart
ConnectivityBanner(
  child: YourApp(),
)
```

### Image Handling
```dart
// Pick and compress
final file = await ImageService().pickWithDialog(context);
final compressed = await ImageService().compressImage(file);

// Display cached
AppNetworkImage(imageUrl: 'https://...', width: 100, height: 100)
```

### Analytics
```dart
await AnalyticsService().logEvent('button_tap', {'button': 'submit'});
await AnalyticsEvents.featureUsed('dark_mode');
```

## 🔗 Backend

This template is designed to work with [cuisonenrico/be-template](https://github.com/cuisonenrico/be-template) - a NestJS backend with OAuth, Supabase, and Redis.

## 📄 License

MIT License

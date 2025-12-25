# Flutter Template with Authentication & Redux

A production-ready Flutter template with basic authentication, MVC architecture, and Async Redux state management.

## Features

- ✅ **Authentication System**: Login/Register with JWT token management
- ✅ **MVC Architecture**: Organized code structure with Models, Views, and Controllers
- ✅ **Async Redux**: Predictable state management with actions and reducers
- ✅ **API Integration**: HTTP service with error handling and token management
- ✅ **Hive Database**: Offline-first local database with automatic caching
- ✅ **Notifications**: Local and push notifications with permission handling
- ✅ **Persistent Storage**: SharedPreferences for local data storage
- ✅ **Routing**: Clean route management with GoRouter
- ✅ **Material Design 3**: Modern theming with light/dark mode support
- ✅ **Build Flavors**: Development, staging, and production environments
- ✅ **Counter Demo**: Sample implementation showing Redux patterns
- ✅ **Mason Bricks**: Fully automated code generation for new features

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart    # API URLs, routes, keys
│   │   └── app_theme.dart        # App theming and colors
│   ├── router/
│   │   └── app_router.dart       # Route configuration
│   ├── services/
│   │   └── api_service.dart      # HTTP client wrapper
│   ├── store/
│   │   └── app_state.dart        # Redux app state
│   └── utils/
│       └── storage_helper.dart   # SharedPreferences wrapper
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   │   └── auth_actions.dart # Authentication Redux actions
│   │   ├── models/
│   │   │   └── auth_models.dart  # User and auth response models
│   │   └── views/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   └── counter/
│       ├── controllers/
│       │   └── counter_actions.dart # Counter Redux actions
│       └── views/
│           └── counter_screen.dart
├── shared/
│   └── widgets/
│       ├── common_widgets.dart   # Reusable UI components
│       └── home_screen.dart      # Main dashboard
└── main.dart                     # App entry point
```

## Getting Started

### 1. Quick Setup (Recommended)

### 2. Manual Setup (Alternative)

```bash
# Clone the template
git clone <repository-url>
cd template

# Get dependencies
flutter pub get

# Rename your app
dart run rename setAppName --targets ios,android,web --value "Your App"
dart run rename setBundleId --targets ios,android --value "com.company.app"

# Run code generation
dart run build_runner build --delete-conflicting-outputs
```

### 3 up your API base URL
- Create environment configuration files
- Install Mason CLI (optional)
- Run code generation automatically

### 2. Manual Setup (Alternative)

```b3. Configuration

Update the API configuration in `lib/core/constants/app_constants.dart` (if not using setup script):

```dart
class AppConstants {
  // Update with your API base URL
  static const String baseUrl = 'https://your-api.com';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  // ... other endpoints
}
```

Or use environment files (`.env.development`, `.env.staging`, `.env.production`):
```bash
API_BASE_URL=https://api.yourapp.com
APP_NAME=My Awesome App
```

### 4. Run the App

```bash
# Using environment configuration
./scripts/run.sh development

# Or standard Flutter run
**Bundle ID Updates:**
- `android/app/build.gradle` - Android package name
- `ios/Runner.xcodeproj/project.pbxproj` - iOS bundle identifier
- `android/app/src/main/AndroidManifest.xml` - Android package
- `android/app/src/main/kotlin/` - Kotlin package structure

### 4. Run the App

```bash
flutter run
```

## Authentication Flow

### Expected API Response Format

**Login/Register Response:**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh_token": "def50200a8b1f...",
  "user": {
    "id": "1",
    "email": "user@example.com",
    "name": "John Doe",
    "avatar": null,
    "created_at": "2024-01-01T00:00:00Z"
  },
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### Token Management

- Tokens are automatically stored in SharedPreferences
- API requests include Bearer token in Authorization header
- Automatic token refresh (implement the refresh endpoint in your backend)
- Logout clears all stored authentication data

## GoRouter Navigation Architecture

### Route Structure

```
/                     → Redirects based on auth state
├── /login           → Login screen
├── /register        → Registration screen  
├── /home            → Main dashboard
│   └── /counter     → Counter feature (nested)
└── /counter         → Redirects to /home/counter
```

### Web-Specific Features

- **URL Management**: Clean, readable URLs for all screens
- **Deep Linking**: Direct access to any screen via URL
- **Browser Integration**: Native back/forward button support
- **Responsive Transitions**: Fade for web, slide for mobile
- **Error Handling**: Custom 404 page with navigation

### Navigation Best Practices

```dart
// ✅ Use extension methods for type safety
context.goToCounter();

// ✅ Use direct GoRouter for dynamic routes  
context.go('/profile/${userId}');

// ❌ Avoid Navigator.push with GoRouter
// Navigator.pushNamed(context, '/counter'); // Don't use
```

## Modern Theming System with Dark Mode

### Comprehensive Theme Architecture

This template includes a **production-ready theming system** with:

- ✅ **Material Design 3** - Latest Material You specifications
- ✅ **Dark Mode Support** - Automatic system detection + manual override
- ✅ **Theme Persistence** - User preferences saved locally
- ✅ **Design Tokens** - Consistent spacing, colors, and typography
- ✅ **Theme Switching** - Multiple UI components for theme selection

### Theme Features

#### **🎨 Design System**
```dart
// Spacing tokens
AppTheme.space8    // 8px
AppTheme.space16   // 16px  
AppTheme.space24   // 24px
AppTheme.space32   // 32px

// Radius tokens
AppTheme.radiusXs   // 4px
AppTheme.radiusSm   // 8px
AppTheme.radiusMd   // 12px
AppTheme.radiusLg   // 16px

// Context extensions
context.colors.primary     // Current theme primary color
context.textStyles.headlineMedium  // Material 3 typography
context.space16          // Easy spacing access
context.radiusMd         // Easy radius access
```

#### **🌙 Theme Modes**
- **Light Mode** - Clean, bright interface
- **Dark Mode** - OLED-friendly dark interface  
- **System Mode** - Follows device preference automatically

#### **💾 Persistence**
Theme preferences are automatically saved and restored across app sessions.

### Using the Theme System

#### **Adding Theme Switcher to UI**

```dart
// Icon button (compact)
ThemeSwitcher(
  type: ThemeSwitcherType.iconButton,
  showLabel: false,
)

// Dropdown menu
ThemeSwitcher(
  type: ThemeSwitcherType.dropdown,
  showLabel: true,
)

// Segmented buttons
ThemeSwitcher(
  type: ThemeSwitcherType.segmentedButton,
  showLabel: true,
)

// Settings list tile
ThemeSwitcher(
  type: ThemeSwitcherType.listTile,
)
```

#### **Programmatic Theme Changes**

```dart
// Change to specific theme
dispatch(ChangeThemeAction(AppThemeMode.dark));

// Toggle between light/dark
dispatch(ToggleThemeAction());

// Access current theme
final currentTheme = store.state.theme.themeMode;
```

#### **Custom Styling with Theme**

```dart
Container(
  padding: EdgeInsets.all(context.space16),
  decoration: BoxDecoration(
    color: context.colors.surface,
    borderRadius: BorderRadius.circular(context.radiusMd),
    border: Border.all(color: context.colors.outline),
  ),
  child: Text(
    'Themed Container',
    style: context.textStyles.bodyMedium?.copyWith(
      color: context.colors.onSurface,
    ),
  ),
)
```

### Theme Architecture

#### **File Structure**
```
lib/core/
├── constants/
│   └── app_theme.dart          # Main theme definitions
├── store/substates/
│   └── theme_state.dart        # Theme state management
└── utils/
    └── storage_helper.dart     # Theme persistence

lib/features/theme/
├── controllers/
│   └── theme_actions.dart      # Theme Redux actions
└── widgets/
    └── theme_switcher.dart     # UI components
```

### Theme Customization

#### **Brand Colors**
Update in `lib/core/constants/app_theme.dart`:
```dart
static const Color seedColor = Color(0xFF2196F3);  // Your brand color
static const Color brandPrimary = Color(0xFF1976D2);
```

#### **Design Tokens**
Modify spacing, radius, and elevation systems:
```dart
// Custom spacing scale
static const double space6 = 6.0;   // Add custom values
static const double space28 = 28.0;

// Custom radius scale  
static const double radiusXxl = 32.0;

// Custom elevation
static const double elevation12 = 12.0;
```

#### **Pre-themed Components**
All Material components include consistent styling:
- **Cards** - Proper elevation, radius, and clipping
- **Buttons** - Consistent padding, shapes, and states  
- **Input Fields** - Filled styling with proper focus states
- **App Bars** - Proper contrast and system overlay styles
- **Dialogs & Sheets** - Rounded corners and appropriate elevation
- **Navigation** - Consistent theming across all navigation types

## Hive Database - Offline-First Storage

### What is Hive?

Hive is a **lightweight, fast NoSQL database** built for Flutter. This template integrates Hive for offline-first data persistence with automatic caching.

### Key Features

- ✅ **Offline-First**: All data is cached locally
- ✅ **Automatic Caching**: API responses automatically saved
- ✅ **Fallback Support**: Loads from cache when API fails
- ✅ **Type-Safe**: Full Dart type safety with Freezed
- ✅ **Zero Configuration**: Mason brick handles everything
- ✅ **Fast Performance**: ~1M operations per second

### How It Works

When you generate a feature with Mason, it automatically:
1. Adds `@HiveType` and `@HiveField` annotations to models
2. Creates CRUD actions with automatic Hive caching
3. Registers Hive adapter in `main_common.dart`
4. Generates Hive adapter via build_runner

**Example offline-first flow:**
```dart
// Fetch action tries API first, falls back to Hive cache
class FetchProductsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      // 1. Try API
      final response = await apiService.get('/products');
      if (response.success) {
        await _cacheItems(items);  // Cache in Hive
        return state.copyWith(products: items);
      }
      
      // 2. Fallback to Hive cache
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(products: cachedItems);
      }
    } catch (e) {
      // 3. Error fallback
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(products: cachedItems);
      }
    }
  }
}
```

📖 **[Read full Hive integration guide →](HIVE_INTEGRATION.md)**
 + Hive support
- ✅ Creates Redux actions for CRUD operations with Hive caching
- ✅ Builds UI screens with StoreConnector
- ✅ **Adds route to `app_router.dart`** with navigation extensions
- ✅ **Registers Hive adapter** for offline-first persistence
- ✅ **Updates AppState** with new feature state
- ✅ **Runs build_runner** to generate code
- ✅ **Creates test file** with sample test

1. Add your state to `AppState` in `lib/core/store/app_state.dart`:

```dart
@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default(AuthState()) AuthState auth,
    @Default(CounterState()) CounterState counter,
    @Default(ThemeState()) ThemeState theme,
    @Default(YourNewState()) YourNewState yourNewFeature, // Add here
  }) = _AppState;
}
```

### Creating Actions

Follow the pattern in `lib/features/counter/controllers/counter_actions.dart`:

```dart
class YourAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // Your logic here
    return state.copy(
      yourNewFeature: state.yourNewFeature.copy(
        // updated properties
      ),
    );
  }
}
```

## Mason Bricks for Code Generation

This template includes **fully automated** Mason bricks for generating new features.

### Install Mason CLI

```bash
dart pub global activate mason_cli
```

### Generate a New Feature

```bash
mason make feature --name profile
```

This **automatically**:
- ✅ Creates complete MVC structure (models, controllers, views)
- ✅ Generates Freezed data models with JSON serialization
- ✅ Creates Redux actions for CRUD operations
- ✅ Builds UI screens with StoreConnector
- ✅ **Adds route to `app_router.dart`** with navigation extensions
- ✅ **Creates and registers state in `app_state.dart`**
- ✅ **Creates state file in `lib/core/store/substates/`**
- ✅ **Adds API endpoints to `app_constants.dart`** (if using API)
- ✅ **Generates test file** with action and model tests
- ✅ **Runs `build_runner` automatically** - code compiles immediately!

After generation, immediately use:
```dart
context.goToProfile();
context.pushProfile();
```

**No manual steps required!** The feature is fully integrated and ready to use.

### What You Get

```
lib/features/profile/
├── controllers/profile_actions.dart   # Redux actions (CRUD)
├── models/profile_models.dart         # Freezed models
└── views/
    ├── profile_screen.dart            # UI
    ├── profile_connector.dart         # StoreConnector
    └── profile_vm.dart                # ViewModel

lib/core/store/substates/
└── profile_state.dart                 # Auto-created state

test/
└── profile_test.dart                  # Unit tests
```

### Available Bricks

- **feature**: Complete feature with full automation

## Customization

### Theming

Update colors and styles in `lib/core/constants/app_theme.dart`:

```dart
class AppTheme {
  static const Color primaryColor = Colors.blue; // Change primary color
  static const Color secondaryColor = Colors.blueAccent;
  // ... other theme properties
}
```

### Navigation & Routing

This template uses **GoRouter** for modern, declarative routing with excellent Flutter web support.

#### Adding New Routes

1. Add your route to `app_router.dart`:
```dart
GoRoute(
  path: '/your-feature',
  name: 'your-feature',
  pageBuilder: (context, state) => _buildPageWithTransition(
    context,
    state,
    const YourFeatureConnector(),
    'Your Feature',
  ),
),
```

2. Use the navigation extensions:
```dart
// Navigate using GoRouter extensions
context.goToHome();
context.goToCounter();
context.goToLogin();

// Or use direct GoRouter methods
context.go('/your-feature');
context.push('/your-feature');
```

#### Web Support Features

- **Direct URLs**: `yourapp.com/counter` works directly
- **Browser Back/Forward**: Full browser navigation support
- **Bookmarking**: Deep linking to any screen
- **SEO Friendly**: Proper URL structure for web
- **Custom Transitions**: Different animations for web vs mobile

### API Endpoints

Update `AppConstants` with your backend endpoints:

```dart
static const String yourEndpoint = '/your-endpoint';
```

## Testing

Run tests:

```bash
flutter test
```

The template includes a basic widget test. Add more tests following Flutter testing patterns.

## Automated Scripts

###x] Automated setup script
- [x] Environment configuration
- [x] Mason brick code generation
- [x] Automatic route registration
- [x] Automatic state management
- [x] Test file generation
- [ ] Update `baseUrl` in environment files
- [ ] Configure app name and package identifier (use `./scripts/setup.sh`)
- [ ] Add proper app icons and splash screen
- [ ] Implement error tracking (Crashlytics, Sentry, etc.)
- [ ] Configure CI/CD pipeline
- [ ] Set up backend API endpoints
Configures app name, bundle ID, API URL, environment files, and more.

### Run Script

Run with environment configuration:
```bash
./scripts/run.sh development   # Dev environment
./scripts/run.sh staging        # Staging environment
./scripts/run.sh production     # Production build
```

### Build Script

Build for specific platforms:
```bash
./scripts/build.sh production apk        # Android APK
./scripts/build.sh staging ios           # iOS staging
./scripts/build.sh development web       # Web development
```

Supported: `apk`, `appbundle`, `ios`, `web`, `windows`, `macos`, `linux`

## Environment Management

This template supports multiple environments out of the box.

### Environment Files

- `.env.development` - Local development
- `.env.staging` - QA/Staging server
- `.env.production` - Production release

Configure in `lib/core/config/env_config.dart`:
```dart
EnvConfig.apiBaseUrl      // Get current API URL
EnvConfig.isDevelopment   // Check environment
EnvConfig.enableLogging   // Feature flags
```

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development guide.

## Production Checklist

- [ ] Update `baseUrl` in AppConstants
- [ ] Configure app name and package identifier
- [ ] Add proper app icons and splash screen
- [ ] Implement error tracking (Crashlytics, Sentry, etc.)
- [ ] Add proper logging
- [ ] Configure CI/CD pipeline
- [ ] Add environment configurations (dev, staging, prod)

## Dependencies

### Core Dependencies
- `async_redux`: State management with theme state included
- `http`: HTTP client
- `shared_preferences`: Local storage with theme persistence
- `hive`: NoSQL database for offline-first data persistence
- `hive_flutter`: Flutter integration for Hive
- `path_provider`: File system paths for Hive
- `flutter_local_notifications`: Local and push notification support
- `permission_handler`: Platform permission management
- `go_router`: Modern declarative routing with Flutter web support
- `freezed`: Immutable state classes with theme state management

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code linting
- `build_runner`: Code generation for Freezed + Hive
- `hive_generator`: Code generation for Hive adapters
- `freezed`: Code generation for immutable classes
- `json_serializable`: JSON serialization code generation

## Contributing

1. Follow the established MVC architecture
2. Use Redux for state management
3. Add proper documentation
4. Include tests for new features
5. Follow Dart/Flutter style guidelines

## License

MIT License - feel free to use this template for your projects.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

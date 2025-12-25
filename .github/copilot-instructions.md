# AI Agent Instructions for Flutter Template Project

## Architecture Overview

This is a **production-ready Flutter template** using **Async Redux** for state management, **GoRouter** for navigation, and **MVC architecture** with feature-based organization.

### Core Patterns

**State Management: Async Redux**
- Single `AppState` at [lib/core/store/app_state.dart](lib/core/store/app_state.dart) composes feature substates (`AuthState`, `CounterState`, `ThemeState`)
- All state classes use **Freezed** for immutability and code generation
- Actions in `controllers/` modify state; never mutate state directly
- Always dispatch actions: `store.dispatch(YourAction())` or `context.dispatch(YourAction())`
- Use `StoreConnector` for reactive UI updates

**Local Database: Hive**
- Fast, lightweight NoSQL database for Flutter
- Type-safe with `@HiveType` and `@HiveField` annotations
- Automatic box creation when generating features with Mason
- HiveService singleton at [lib/core/services/hive_service.dart](lib/core/services/hive_service.dart)
- Offline-first: Data cached locally, synced with API when available
- All CRUD actions auto-handle Hive caching

**Notifications System**
- Local notifications work out of the box
- Push notification ready (Firebase, OneSignal, etc.)
- NotificationManager facade at [lib/core/services/notifications/notification_manager.dart](lib/core/services/notifications/notification_manager.dart)
- Platform permissions pre-configured (iOS, Android)
- Redux actions for all notification operations
- Adapter pattern allows easy service switching

**Code Generation Workflow**
- Models use Freezed + JSON serialization + Hive adapters
- Annotations: `@freezed`, `@HiveType(typeId: X)`, `@HiveField(N)`
- After creating/modifying models, ALWAYS run: `dart run build_runner build --delete-conflicting-outputs`
- Generated files: `*.freezed.dart`, `*.g.dart` (already in repo, excluded from analysis)

**Navigation: GoRouter**
- All routes in [lib/core/router/app_router.dart](lib/core/router/app_router.dart)
- Use context extensions: `context.goToHome()`, `context.goToCounter()`, `context.goToLogin()`
- Web-first design with clean URLs (`/home/counter`, `/login`)
- Auth redirection handled at route level

**Feature Structure (MVC)**
```
lib/features/<feature_name>/
├── controllers/        # Redux actions (business logic)
├── models/            # Freezed data models
└── views/             # UI screens with StoreConnectors
```

## Critical Workflows
Hive integration** - models with `@HiveType` annotations and adapter generation
- ✅ **Hive box creation** - automatic box registration in main_common.dart
- ✅ **Offline-first CRUD** - actions with automatic Hive caching/syncing
- ✅ **Route registration** in [lib/core/router/app_router.dart](lib/core/router/app_router.dart)
- ✅ **State creation** in [lib/core/store/substates/your_feature_state.dart](lib/core/store/substates/)
- ✅ **AppState update** - adds feature state to [lib/core/store/app_state.dart](lib/core/store/app_state.dart)
- ✅ **API endpoints** added to [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
- ✅ **Test file** generation with action and model tests
- ✅ **Build runner** executes automatically after generation
```
This automatically:
- ✅ Complete MVC structure with models, actions, views, and state
- ✅ **Route registration** in [lib/core/router/app_router.dart](lib/core/router/app_router.dart)
- ✅ **State creation** in [lib/core/store/substates/your_feature_state.dart](lib/core/store/substates/)
- ✅ **AppState update** - adds feature state to [lib/core/store/app_state.dart](lib/core/store/app_state.dart)
- ✅ **API endpoints** added to [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
- ✅ **Test file** generation with action and model tests
- ✅Create state file in `lib/core/store/substates/your_feature_state.dart`
3. Add substate to `AppState` in [lib/core/store/app_state.dart](lib/core/store/app_state.dart)
4. Create `models/` with Freezed models
5. Create `controllers/` with Redux actions extending `ReduxAction<AppState>`
6. Create `views/` with screens using `StoreConnector`
7. **Add route** to [lib/core/router/app_router.dart](lib/core/router/app_router.dart):
   - Import connector: `import '../../features/your_feature/views/your_feature_connector.dart';`
   - Add GoRoute with path, name, and pageBuilder
   - Add extension methods: `goToYourFeature()` and `pushYourFeature()`
8. Add API endpoints to [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
9. Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### Initial Project Setup

**Automated setup (recommended):**
```bash
./scripts/setup.sh
```
Configures app name, bundle ID, API URL, environment files, and runs build_runner.

**Environment-based development:**
```bash
./scripts/run.sh development    # Run with dev config
./scripts/build.sh production apk  # Build with prod config
``
4. Create `controllers/` with Redux actions extending `ReduxAction<AppState>`
5. Create `views/` with screens using `StoreConnector`
6. **Add route** to [lib/core/router/app_router.dart](lib/core/router/app_router.dart):
   - Import connector: `import '../../features/your_feature/views/your_feature_connector.dart';`
   - Add GoRoute with path, name, and pageBuilder
   - Add extension methods: `goToYourFeature()` and `pushYourFeature()`
7. Run code generation: `dart run build_runner build --delete-conflicting-outputs`

### API Integration Pattern

See [lib/features/auth/controllers/auth_actions.dart](lib/features/auth/controllers/auth_actions.dart) for reference:
- Use `ApiService()` singleton for HTTP calls
- Store tokens via `StorageHelper` (SharedPreferences wrapper)
- Actions dispatch loading/error states: `SetAuthLoadingAction`, `SetAuthErrorAction`
- API responses expect `{success, data, message}` structure

### Hive Database Pattern

**Offline-First Architecture:**
- All generated features include automatic Hive caching
- Fetch actions try API first, fall back to Hive cache on failure
- Create/Update/Delete actions sync to both API and Hive
- Each feature gets its own Hive box: `{feature_name}_box`

**Hive Type IDs:**
- Each model needs unique typeId starting from 100+
- Mason brick prompts for typeId during generation
- Reserved IDs: 0-99 (Flutter/Hive internal)
- Track used IDs to avoid conflicts

**HiveService Usage:**
```dart
final box = await HiveService().openBox<YourModel>('your_box');
await box.add(item);              // Create
final items = box.values.toList(); // Read all
await box.putAt(index, item);     // Update
await box.deleteAt(index);        // Delete
```

### Theme System

- Material Design 3 with Light/Dark/System modes
- Theme state persisted via `StorageHelper`
- Access design tokens: `context.colors.primary`, `context.textStyles.headlineMedium`, `context.space16`, `context.radiusMd`
- Change theme: `dispatch(ChangeThemeAction(AppThemeMode.dark))`
- Theme switcher components: `ThemeSwitcher(type: ThemeSwitcherType.iconButton)`

## Project-Specific Conventions

**Import Organization**
- Group imports: Flutter SDK → packages → project files
- Use relative imports within features: `'../models/auth_models.dart'`
- Initial setup (one-time)
./scripts/setup.sh

# Run with environment
./scripts/run.sh development
./scripts/run.sh staging
./scripts/run.sh production

# Build with environment
./scripts/build.sh production apk
./scripts/build.sh staging ios

# Get dependencies
flutter pub get

# Run code generation (after model changes)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs

# Run app (standard)
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# ReEnvironment:** [lib/core/config/env_config.dart](lib/core/config/env_config.dart)
- **Auth example:** [lib/features/auth/controllers/auth_actions.dart](lib/features/auth/controllers/auth_actions.dart)
- **Counter example:** [lib/features/counter/](lib/features/counter/)
- **Setup script:** [scripts/setup.sh](scripts/setup.sh)
- **Development guide:** [DEVELOPMENT.md](DEVELOPMENT.mdpp"
dart run rename setBundleId --targets ios,android --value "com.company.app"
```
 (Mason does this automatically)
- **Don't** access SharedPreferences directly; use `StorageHelper`
- **Don't** manually add state to AppState; Mason brick does this automatically
- **Do** dispatch loading/error actions in async operations
- **Do** handle auth token refresh in `ApiService` for 401 responses
- **Do** use Mason brick for new features - it handles all integration automatically
- **Do** use environment-specific scripts for running and buildingction`
- Access config via `EnvConfig` class in [lib/core/config/env_config.dart](lib/core/config/env_config.dart)
- Run with: `flutter run --dart-define-from-file=.env.development`
- Or use: `./scripts/run.sh development
# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs

# Run app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Rename app
dart run rename setAppName --targets ios,android,web --value "Your App"
dart run rename setBundleId --targets ios,android --value "com.company.app"
```

## Key Files to Reference

- **State management:** [lib/core/store/app_state.dart](lib/core/store/app_state.dart)
- **API client:** [lib/core/services/api_service.dart](lib/core/services/api_service.dart)
- **Hive database:** [lib/core/services/hive_service.dart](lib/core/services/hive_service.dart)
- **Notifications:** [lib/core/services/notifications/notification_manager.dart](lib/core/services/notifications/notification_manager.dart)
- **Storage:** [lib/core/utils/storage_helper.dart](lib/core/utils/storage_helper.dart)
- **Routing:** [lib/core/router/app_router.dart](lib/core/router/app_router.dart)
- **Theme:** [lib/core/constants/app_theme.dart](lib/core/constants/app_theme.dart)
- **Environment:** [lib/core/config/env_config.dart](lib/core/config/env_config.dart)
- **Auth example:** [lib/features/auth/controllers/auth_actions.dart](lib/features/auth/controllers/auth_actions.dart)
- **Counter example:** [lib/features/counter/](lib/features/counter/)
- **Notifications guide:** [NOTIFICATIONS.md](NOTIFICATIONS.md)
- **Setup script:** [scripts/setup.sh](scripts/setup.sh)
- **Development guide:** [DEVELOPMENT.md](DEVELOPMENT.md)

## Common Pitfalls

- **Don't** mutate state directly; always return new state from `reduce()`
- **Don't** use `Navigator.push`; use GoRouter context extensions
- **Don't** forget to run `build_runner` after modifying Freezed/Hive models (Mason does this automatically)
- **Don't** access SharedPreferences directly; use `StorageHelper`
- **Don't** manually add state to AppState; Mason brick does this automatically
- **Do** dispatch loading/error actions in async operations
- **Do** handle auth token refresh in `ApiService` for 401 responses
- **Do** use Mason brick for new features - it handles all integration automatically
- **Do** use environment-specific scripts for running and building
- **Do** dispatch loading/error actions in async operations
- **Do** handle auth token refresh in `ApiService` for 401 responses

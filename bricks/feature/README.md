# Feature Brick

Generates a new feature with complete MVC architecture, Redux integration, and automatic route registration.

## What It Creates

- **Models**: Freezed data models with JSON serialization
- **Controllers**: Redux actions for business logic
- **Views**: UI screens with StoreConnector
- **Routes**: Automatically adds routes to `app_router.dart`

## Usage

```bash
mason make feature --name profile
```

This will:
1. Create `lib/features/profile/` with MVC structure
2. Generate models, actions, and views
3. **Automatically update** `lib/core/router/app_router.dart`:
   - Add import for ProfileConnector
   - Add GoRoute for `/profile`
   - Add navigation methods: `context.goToProfile()` and `context.pushProfile()`

## Variables

- `name`: Feature name (e.g., profile, settings, notifications)
- `model_fields`: Optional list of fields (name:type format)
- `has_api`: Whether the feature needs API integration (default: true)

## Example

```bash
# Create a profile feature with API integration
mason make feature --name profile --has_api true

# Create a settings feature without API
mason make feature --name settings --has_api false
```

## After Generation

1. Add your feature state to `AppState` in `lib/core/store/app_state.dart`
2. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
3. Navigate using: `context.goToProfile()` or `context.pushProfile()`

## What Gets Added to app_router.dart

```dart
// Import
import '../../features/profile/views/profile_connector.dart';

// Route
GoRoute(
  path: '/profile',
  name: 'profile',
  pageBuilder: (context, state) =>
      _buildPageWithTransition(context, state, const ProfileConnector(), 'Profile'),
),

// Extension methods
void goToProfile() => go('/profile');
void pushProfile() => push('/profile');
```

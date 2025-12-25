# Mason Feature Brick - Quick Reference

## Quick Start

```bash
mason make feature --name my_feature
```

## What Happens Automatically

### 1. File Generation
```
lib/features/my_feature/
├── models/my_feature_models.dart          # Freezed data models
├── controllers/my_feature_actions.dart    # Redux actions
└── views/
    ├── my_feature_screen.dart             # UI screen
    ├── my_feature_connector.dart          # StoreConnector
    └── my_feature_vm.dart                 # ViewModel factory
```

### 2. Route Registration (Automatic!)
The hook automatically updates `lib/core/router/app_router.dart`:

**Adds import:**
```dart
import '../../features/my_feature/views/my_feature_connector.dart';
```

**Adds route:**
```dart
GoRoute(
  path: '/my-feature',
  name: 'my_feature',
  pageBuilder: (context, state) =>
      _buildPageWithTransition(context, state, const MyFeatureConnector(), 'MyFeature'),
),
```

**Adds navigation methods:**
```dart
extension AppRouterExtension on BuildContext {
  // ... existing methods
  void goToMyFeature() => go('/my-feature');
  void pushMyFeature() => push('/my-feature');
}
```

## Next Steps After Generation

1. **Add state to AppState**
   ```dart
   // lib/core/store/app_state.dart
   @freezed
   class AppState with _$AppState {
     const factory AppState({
       @Default(AuthState()) AuthState auth,
       @Default(MyFeatureState()) MyFeatureState myFeature,  // Add this
     }) = _AppState;
   }
   ```

2. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Navigate to your feature**
   ```dart
   context.goToMyFeature();
   ```

## Tips

- Use `snake_case` for feature names (e.g., `user_profile`, `app_settings`)
- Routes are automatically kebab-cased (e.g., `/user-profile`)
- Navigation methods are PascalCased (e.g., `goToUserProfile()`)
- All routes support web direct URLs out of the box

# Authentication System

This template uses a **modern OAuth-based authentication system** that works with the [be-template](https://github.com/cuisonenrico/be-template) backend. Firebase is **optional** and can be enabled if needed.

## Quick Start

### 1. Backend Setup

Ensure your backend (be-template) is running with OAuth endpoints:
- `POST /oauth/register` - Email/password registration
- `POST /oauth/login` - Email/password login
- `GET /oauth/providers` - Available OAuth providers (Google, etc.)
- `GET /oauth/authorize/:provider/url` - Get OAuth URL
- `GET /oauth/callback/:provider` - Handle OAuth callback
- `POST /oauth/refresh` - Refresh tokens
- `POST /oauth/logout` - Logout

### 2. Configure API URL

Update your API base URL in `lib/core/config/app_flavor.dart` or environment files.

### 3. Firebase (Optional)

By default, Firebase is **disabled**. To enable:

```dart
// In lib/main_common.dart
const bool useFirebaseAuth = true;  // Change to true
```

## Authentication Flow

### Email/Password Login

```dart
// From a button press
dispatch(LoginAction(email: 'user@example.com', password: 'password'));

// The action:
// 1. Calls POST /oauth/login
// 2. Stores access_token and refresh_token automatically
// 3. Updates AuthState with user data
// 4. Router automatically redirects to /home
```

### Email/Password Registration

```dart
dispatch(RegisterAction(
  email: 'user@example.com',
  password: 'password',
  name: 'John Doe',
));
```

### Google OAuth Sign-In

The Google OAuth flow is a two-step process:

```dart
// Step 1: Get OAuth URL
dispatch(GetOAuthUrlAction(
  provider: 'google',
  onSuccess: (url) {
    // Open URL in browser/webview
    launchUrl(Uri.parse(url));
  },
  onError: (error) => print('Error: $error'),
));

// Step 2: Handle callback with authorization code
// (After user completes OAuth in browser)
dispatch(GoogleSignInAction(authorizationCode: code));
```

For mobile apps, you'll need to:
1. Configure deep linking to handle the OAuth callback
2. Extract the `code` parameter from the callback URL
3. Call `GoogleSignInAction` with the code

### Logout

```dart
// Single session logout
dispatch(LogoutAction());

// Logout from all devices
dispatch(LogoutAllDevicesAction());
```

## Auth State

The auth state is managed in Redux:

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoggedIn,
    @Default(false) bool isLoading,
    User? user,
    String? accessToken,
    String? refreshToken,
    String? error,
  }) = _AuthState;
}
```

### Checking Auth State

```dart
// In a widget
StoreConnector<AppState, bool>(
  converter: (store) => store.state.auth.isLoggedIn,
  builder: (context, isLoggedIn) {
    return Text(isLoggedIn ? 'Logged In' : 'Logged Out');
  },
);
```

## Available Auth Actions

| Action | Description |
|--------|-------------|
| `LoginAction` | Email/password login |
| `RegisterAction` | Email/password registration |
| `GoogleSignInAction` | Complete Google OAuth with code |
| `GetOAuthUrlAction` | Get OAuth provider URL |
| `LogoutAction` | Logout current session |
| `LogoutAllDevicesAction` | Logout from all devices |
| `RefreshTokenAction` | Manually refresh tokens |
| `CheckAuthStatusAction` | Check stored auth state on app start |
| `ChangePasswordAction` | Change user password |
| `DeleteAccountAction` | Permanently delete account |
| `GetSessionsAction` | Get active sessions |
| `RevokeSessionAction` | Revoke a specific session |
| `SetAuthLoadingAction` | Set loading state |
| `SetAuthErrorAction` | Set error state |
| `ClearAuthErrorAction` | Clear error state |

## Automatic Token Refresh

The `ApiService` automatically handles 401 errors:

1. When a request returns 401 (Unauthorized)
2. The service automatically attempts to refresh the token
3. If successful, the original request is retried
4. If refresh fails, user is logged out

This is transparent to the developer - just use `requiresAuth: true`:

```dart
final response = await ApiService().get('/users', requiresAuth: true);
```

## Route Protection

Routes are automatically protected via `AuthNotifier`:

```dart
// In app_router.dart
redirect: (context, state) {
  final isLoggedIn = store.state.auth.isLoggedIn;
  final isGoingToLogin = state.matchedLocation == '/login';
  
  // Not logged in -> redirect to login
  if (!isLoggedIn && !isGoingToLogin) {
    return '/login';
  }
  
  // Logged in and going to login -> redirect to home
  if (isLoggedIn && isGoingToLogin) {
    return '/home';
  }
  
  return null;
},
```

## API Response Format

The backend should return tokens in this format:

```json
{
  "message": "Login successful",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "avatarUrl": "https://..."
  },
  "accessToken": "eyJ...",
  "refreshToken": "def50...",
  "expiresIn": 900
}
```

## Storage

Tokens are stored securely using SharedPreferences:

```dart
// Automatically handled by auth actions
await StorageHelper.saveAccessToken(token);
await StorageHelper.saveRefreshToken(refreshToken);
await StorageHelper.saveUserData(user.toJson());
await StorageHelper.setLoggedIn(true);

// On logout
await StorageHelper.clearUserSession();
```

## Error Handling

Auth errors are stored in state and displayed in UI:

```dart
// In LoginScreen
if (widget.error != null)
  Container(
    child: Text(widget.error!),
  ),
```

Clear errors before new attempts:

```dart
widget.onClearError();
widget.onLogin(email, password);
```

## OAuth Endpoints Reference

### Public Endpoints (No Auth Required)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/oauth/register` | POST | Register with email/password |
| `/oauth/login` | POST | Login with email/password |
| `/oauth/providers` | GET | Get available OAuth providers |
| `/oauth/authorize/:provider/url` | GET | Get OAuth authorization URL |
| `/oauth/callback/:provider` | GET | Handle OAuth callback |
| `/oauth/refresh` | POST | Refresh tokens |

### Protected Endpoints (Auth Required)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/oauth/logout` | POST | Logout (single session) |
| `/oauth/logout/all` | POST | Logout from all devices |
| `/oauth/me` | GET | Get user profile with linked accounts |
| `/oauth/sessions` | GET | Get active sessions |
| `/oauth/sessions/:id` | DELETE | Revoke specific session |
| `/oauth/link/:provider` | GET | Link additional OAuth provider |
| `/oauth/accounts/:provider` | DELETE | Unlink OAuth provider |
| `/oauth/me/password` | POST | Change password |
| `/oauth/me` | DELETE | Delete account |

## Deep Linking Setup (for OAuth callbacks)

### iOS (ios/Runner/Info.plist)

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>OAuth Callback</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>yourapp</string>
    </array>
  </dict>
</array>
```

### Android (android/app/src/main/AndroidManifest.xml)

```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW"/>
  <category android:name="android.intent.category.DEFAULT"/>
  <category android:name="android.intent.category.BROWSABLE"/>
  <data android:scheme="yourapp" android:host="oauth"/>
</intent-filter>
```

### Handling the Callback

```dart
// Using go_router deep linking
GoRoute(
  path: '/oauth/callback',
  redirect: (context, state) {
    final code = state.uri.queryParameters['code'];
    if (code != null) {
      store.dispatch(GoogleSignInAction(authorizationCode: code));
    }
    return '/home';
  },
),
```

## Customizing Auth UI

The login/register screens are in:
- `lib/features/auth/views/login_screen.dart`
- `lib/features/auth/views/register_screen.dart`

The ViewModels are in:
- `lib/features/auth/views/login_vm.dart`
- `lib/features/auth/views/register_vm.dart`

## Troubleshooting

### "Token refresh failed"
- Check that your backend is running
- Verify the refresh token endpoint is correct
- Check if the refresh token has expired

### "Invalid response from server"
- Ensure your backend returns the expected JSON format
- Check that `user` object is included in response

### OAuth flow not working
- Verify deep linking is configured correctly
- Check that callback URL matches backend configuration
- Ensure the provider is configured in backend (.env)

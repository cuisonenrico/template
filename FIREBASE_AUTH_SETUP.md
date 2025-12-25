# Firebase Authentication Setup Guide

## Overview

The app now includes Firebase Authentication with:
- ✅ Email/Password authentication
- ✅ Google Sign-In
- ✅ Seamless integration with existing Redux architecture
- ✅ Optional backend API synchronization
- ✅ Beautiful error messages
- ✅ Comprehensive logging

## Setup Instructions

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select existing project
3. Follow the setup wizard

### 2. Add Firebase to Your Flutter App

#### For iOS:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Create `firebase_options.dart`
- Download `GoogleService-Info.plist` for iOS
- Download `google-services.json` for Android

#### Manual iOS Setup (if needed):

1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner/` directory in Xcode
3. Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

#### For Android:

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Update `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    // Add this line
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

4. Update `android/app/build.gradle`:

```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Add this line
}
```

### 3. Enable Authentication Methods

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** (add your app's SHA-1 certificate for Android)

#### Get SHA-1 for Android:

```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 and add it in Firebase Console → Project Settings → Your Android app

### 4. Google Sign-In Assets

Download the Google logo and add it to your project:

```bash
# Create assets directory
mkdir -p assets/images

# Download Google logo or use your own
# Place google_logo.png in assets/images/
```

Update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/google_logo.png
```

### 5. Install Dependencies

```bash
flutter pub get
```

### 6. Import Firebase Options

After running `flutterfire configure`, import the generated file in `main_common.dart`:

```dart
import 'firebase_options.dart';

// Update Firebase initialization:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Usage

### Login with Email/Password

```dart
// Automatically handled in LoginScreen
// User enters email and password, clicks "Login"
```

### Google Sign-In

```dart
// Automatically handled in LoginScreen
// User clicks "Continue with Google" button
```

### Programmatic Authentication

```dart
// In your Redux actions or services:

// Email/Password Sign In
final result = await FirebaseAuthService().signInWithEmailPassword(
  email: 'user@example.com',
  password: 'password123',
);

if (result.success) {
  print('Signed in: ${result.userId}');
} else {
  print('Error: ${result.errorMessage}');
}

// Google Sign In
final result = await FirebaseAuthService().signInWithGoogle();

// Sign Out
await FirebaseAuthService().signOut();

// Get current user
final user = FirebaseAuthService().currentUser;
final userId = FirebaseAuthService().currentUserId;

// Get Firebase ID token (for backend API)
final idToken = await FirebaseAuthService().getIdToken();
```

## Backend Integration

The auth actions automatically sync with your backend API:

1. **Login Flow:**
   - User authenticates with Firebase
   - Get Firebase ID token
   - Send token to backend `/api/auth/login`
   - Backend verifies token and returns user data
   - Store user data in Redux state

2. **Backend API Expects:**

```json
POST /api/auth/login
{
  "firebase_token": "eyJhbGciOiJSUzI1NiIs...",
  "email": "user@example.com",
  "provider": "google" // or "email"
}

Response:
{
  "success": true,
  "data": {
    "access_token": "backend_jwt_token",
    "refresh_token": "refresh_token",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name",
      "avatar": "https://..."
    }
  }
}
```

### Backend-Only Mode (No Firebase)

If you want to use only your backend without Firebase, the original login actions are preserved. Just remove Firebase initialization and use the old `LoginAction`.

## Architecture

### Files Created/Updated:

- `lib/core/services/firebase_auth_service.dart` - Firebase auth wrapper
- `lib/features/auth/controllers/auth_actions.dart` - Updated with Firebase
- `lib/features/auth/views/login_screen.dart` - Added Google Sign-In button
- `lib/features/auth/views/login_vm.dart` - Added Google Sign-In action
- `lib/features/auth/views/login_connector.dart` - Connected Google Sign-In
- `lib/main_common.dart` - Added Firebase initialization

### Authentication Flow:

```
User Input → LoginScreen → LoginAction (Redux)
           ↓
Firebase Auth (email/password or Google)
           ↓
Get Firebase ID Token
           ↓
Optional: Sync with Backend API
           ↓
Update Redux State (user logged in)
           ↓
Navigate to Home
```

## Error Handling

All Firebase errors are converted to user-friendly messages:

```dart
'user-not-found' → 'No account found with this email'
'wrong-password' → 'Incorrect password'
'email-already-in-use' → 'An account already exists with this email'
'weak-password' → 'Password is too weak'
// ... and more
```

## Security Best Practices

1. **Never store passwords** - Firebase handles this
2. **Use Firebase ID tokens** for backend authentication
3. **Validate tokens** on your backend:

```javascript
// Node.js example
const admin = require('firebase-admin');

async function verifyToken(idToken) {
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken.uid;
  } catch (error) {
    throw new Error('Invalid token');
  }
}
```

4. **Set up Firebase Security Rules** in Firebase Console
5. **Enable App Check** for additional security

## Testing

### Test Accounts

Create test accounts in Firebase Console → Authentication → Users

### Debug Mode

Check Firebase Authentication logs:
- All auth operations are logged with `AppLogger`
- Check debug console for detailed logs

## Troubleshooting

### iOS: "No Firebase App '[DEFAULT]' has been created"

- Ensure `GoogleService-Info.plist` is added to Xcode project
- Run `flutterfire configure` again
- Clean and rebuild: `flutter clean && flutter pub get`

### Android: "Default FirebaseApp is not initialized"

- Ensure `google-services.json` is in `android/app/`
- Check `google-services` plugin is applied in `build.gradle`
- Sync Gradle files

### Google Sign-In Not Working

- Verify SHA-1 is added in Firebase Console
- Check `REVERSED_CLIENT_ID` in iOS `Info.plist`
- Ensure Google Sign-In is enabled in Firebase Console

### Backend Sync Failing

- The app will fallback to Firebase user data if backend fails
- Check API endpoints in `app_constants.dart`
- Verify backend is accepting `firebase_token`

## Additional Features

### Password Reset

```dart
final result = await FirebaseAuthService().sendPasswordResetEmail(
  'user@example.com',
);
```

### Delete Account

```dart
final result = await FirebaseAuthService().deleteAccount();
```

### Listen to Auth State

```dart
FirebaseAuthService().authStateChanges.listen((user) {
  if (user != null) {
    print('User is signed in: ${user.uid}');
  } else {
    print('User is signed out');
  }
});
```

## Next Steps

1. Run `flutterfire configure`
2. Add `GoogleService-Info.plist` and `google-services.json`
3. Enable auth methods in Firebase Console
4. Add Google logo to assets
5. Test email/password and Google sign-in
6. Configure your backend to accept Firebase tokens

## Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)

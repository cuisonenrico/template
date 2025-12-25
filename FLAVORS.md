# Build Flavors Configuration

This template includes proper **build flavors** for development, staging, and production environments.

## What Are Build Flavors?

Build flavors allow you to create different versions of your app from the same codebase:
- Different app names (e.g., "MyApp Dev", "MyApp Staging", "MyApp")
- Different bundle IDs (e.g., com.company.app.dev, com.company.app.staging, com.company.app)
- Different configurations (API URLs, feature flags, etc.)
- **Install all flavors side-by-side** on the same device!

---

## Available Flavors

### 🟢 Development
- **App Name:** Template Dev
- **Bundle ID:** com.example.template.dev
- **API:** Dev API endpoint
- **Features:** Debug logging, no analytics
- **Target:** `lib/main.dart`

### 🟡 Staging
- **App Name:** Template Staging
- **Bundle ID:** com.example.template.staging
- **API:** Staging API endpoint
- **Features:** Debug logging, analytics enabled
- **Target:** `lib/main_staging.dart`

### 🔴 Production
- **App Name:** Template
- **Bundle ID:** com.example.template
- **API:** Production API endpoint
- **Features:** No debug logging, analytics enabled
- **Target:** `lib/main_production.dart`

---

## Running with Flavors

### Command Line

```bash
# Development flavor (default)
flutter run --flavor development --target lib/main.dart

# Staging flavor
flutter run --flavor staging --target lib/main_staging.dart

# Production flavor
flutter run --flavor production --target lib/main_production.dart
```

### Using Scripts (Recommended)

```bash
./scripts/run.sh development
./scripts/run.sh staging
./scripts/run.sh production
```

---

## Building with Flavors

### Android

```bash
# Development APK
flutter build apk --flavor development --target lib/main.dart

# Staging App Bundle
flutter build appbundle --flavor staging --target lib/main_staging.dart

# Production APK
flutter build apk --flavor production --target lib/main_production.dart
```

### iOS

```bash
# Development build
flutter build ios --flavor development --target lib/main.dart

# Staging build
flutter build ios --flavor staging --target lib/main_staging.dart

# Production build
flutter build ios --flavor production --target lib/main_production.dart
```

### Using Scripts (Recommended)

```bash
# Android builds
./scripts/build.sh development apk
./scripts/build.sh staging appbundle
./scripts/build.sh production apk

# iOS builds
./scripts/build.sh development ios
./scripts/build.sh staging ios
./scripts/build.sh production ios
```

---

## VS Code Launch Configurations

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--flavor",
        "development",
        "--dart-define-from-file=.env.development"
      ]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart",
      "args": [
        "--flavor",
        "staging",
        "--dart-define-from-file=.env.staging"
      ]
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_production.dart",
      "args": [
        "--flavor",
        "production",
        "--dart-define-from-file=.env.production"
      ]
    }
  ]
}
```

Now you can select flavor from VS Code's Run menu!

---

## Android Studio / IntelliJ

1. Click on configuration dropdown
2. Click "Edit Configurations"
3. Add new Flutter configuration
4. Set:
   - **Name:** Development / Staging / Production
   - **Dart entrypoint:** `lib/main.dart` / `lib/main_staging.dart` / `lib/main_production.dart`
   - **Additional run args:** `--flavor development` (or staging/production)

---

## Accessing Flavor in Code

```dart
import 'package:template/core/config/app_flavor.dart';

// Get current flavor
final flavor = AppFlavor.current;

// Check flavor
if (flavor.isDevelopment) {
  print('Running in development mode');
}

if (flavor.isProduction) {
  // Disable debug features
}

// Get flavor-specific values
final apiUrl = flavor.apiBaseUrl;
final appName = flavor.appName;

// Conditional logging
flavor.logDebug('This only prints in dev/staging');

// Feature flags
if (flavor.enableAnalytics) {
  // Initialize analytics
}
```

---

## Architecture

### File Structure

```
lib/
├── main.dart              # Development entry (AppFlavor.development)
├── main_staging.dart      # Staging entry (AppFlavor.staging)
├── main_production.dart   # Production entry (AppFlavor.production)
├── main_common.dart       # Shared initialization logic
└── core/config/
    └── app_flavor.dart    # Flavor configuration
```

### How It Works

1. Each `main_*.dart` calls `mainCommon()` with specific flavor
2. `mainCommon()` sets the flavor globally
3. `AppFlavor.current` provides access throughout the app
4. Flavor determines API URLs, app name, feature flags, etc.

---

## Android Configuration

**File:** `android/app/build.gradle.kts`

```kotlin
flavorDimensions += "environment"
productFlavors {
    create("development") {
        dimension = "environment"
        applicationIdSuffix = ".dev"
        versionNameSuffix = "-dev"
        resValue("string", "app_name", "Template Dev")
    }
    create("staging") {
        dimension = "environment"
        applicationIdSuffix = ".staging"
        versionNameSuffix = "-staging"
        resValue("string", "app_name", "Template Staging")
    }
    create("production") {
        dimension = "environment"
        resValue("string", "app_name", "Template")
    }
}
```

This creates different app IDs and names for each flavor.

---

## iOS Configuration

For iOS, you'll need to:

1. **Create Schemes in Xcode:**
   - Open `ios/Runner.xcworkspace`
   - Product → Scheme → New Scheme
   - Create schemes for: Development, Staging, Production

2. **Configure Build Settings:**
   - Set bundle identifier per scheme
   - Set app name per scheme
   - Configure build configurations

3. **Or use `xcconfig` files:**

Create `ios/Flutter/Development.xcconfig`:
```
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.template.dev
PRODUCT_NAME = Template Dev
```

Create `ios/Flutter/Staging.xcconfig`:
```
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.template.staging
PRODUCT_NAME = Template Staging
```

Create `ios/Flutter/Production.xcconfig`:
```
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.example.template
PRODUCT_NAME = Template
```

---

## Environment Variables + Flavors

Flavors work **together** with environment variables:

```bash
# Flavor determines WHICH .env file to use
./scripts/run.sh development  # Uses .env.development
./scripts/run.sh staging       # Uses .env.staging
./scripts/run.sh production    # Uses .env.production
```

Flavor provides:
- ✅ Different app names
- ✅ Different bundle IDs
- ✅ Side-by-side installation
- ✅ Type-safe configuration

Environment variables provide:
- ✅ Secure credentials
- ✅ Per-environment settings
- ✅ Easy configuration changes

---

## Benefits Over Simple Environment Variables

| Feature | Env Vars Only | Build Flavors |
|---------|--------------|---------------|
| Different API URLs | ✅ | ✅ |
| Different bundle IDs | ❌ | ✅ |
| Different app names | ❌ | ✅ |
| Side-by-side install | ❌ | ✅ |
| Type-safe config | ❌ | ✅ |
| IDE integration | Limited | Full |
| Platform-native | ❌ | ✅ |

---

## Testing Flavors

```bash
# Run tests with specific flavor
flutter test --flavor development --dart-define-from-file=.env.development

# Or use default (development)
flutter test
```

---

## CI/CD Integration

### GitHub Actions

```yaml
- name: Build Development APK
  run: |
    flutter build apk \
      --flavor development \
      --target lib/main.dart \
      --dart-define-from-file=.env.development

- name: Build Production APK
  run: |
    flutter build apk \
      --flavor production \
      --target lib/main_production.dart \
      --dart-define-from-file=.env.production
```

---

## Troubleshooting

### "No flavor defined"
Make sure you're using `--flavor` flag:
```bash
flutter run --flavor development
```

### "No such file or directory: main_staging.dart"
Ensure all main files exist:
- `lib/main.dart`
- `lib/main_staging.dart`
- `lib/main_production.dart`

### Android build fails
Clean and rebuild:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Can't install multiple flavors on iOS
Ensure each flavor has different bundle ID in Xcode schemes.

---

## Best Practices

1. **Always use scripts** - `./scripts/run.sh development`
2. **Never hardcode flavor checks** - Use `AppFlavor.current`
3. **Keep flavor logic in `app_flavor.dart`** - Don't scatter it
4. **Use environment files** - Don't hardcode API URLs
5. **Test all flavors** - Before release, verify all work
6. **Document custom configs** - If you add flavor-specific features

---

**Build flavors give you production-grade environment management! 🚀**

# Scripts Directory

Automated scripts for Flutter template management.

## Available Scripts

### 🚀 setup.sh
**Purpose:** Initial project setup wizard

**Usage:**
```bash
./scripts/setup.sh
```

**What it does:**
- Prompts for app name
- Prompts for bundle ID
- Prompts for API base URL
- Updates all platform configurations
- Creates environment files
- Optionally installs Mason CLI
- Runs code generation

**When to use:** Once per new project

---

### ▶️ run.sh
**Purpose:** Run app with environment configuration

**Usage:**
```bash
./scripts/run.sh [development|staging|production]
```

**Examples:**
```bash
./scripts/run.sh development   # Run with dev config
./scripts/run.sh staging        # Run with staging config  
./scripts/run.sh production     # Run with prod config (release mode)
```

**What it does:**
- Loads environment from `.env.[environment]`
- Passes configuration to Flutter via `--dart-define-from-file`
- Runs in release mode for production

**When to use:** Daily development

---

### 🏗️ build.sh
**Purpose:** Build app for specific platform and environment

**Usage:**
```bash
./scripts/build.sh [environment] [platform]
```

**Environments:**
- `development`
- `staging`
- `production`

**Platforms:**
- `apk` - Android APK
- `appbundle` - Android App Bundle
- `ios` - iOS
- `web` - Web
- `windows` - Windows
- `macos` - macOS
- `linux` - Linux

**Examples:**
```bash
./scripts/build.sh production apk        # Prod Android APK
./scripts/build.sh staging ios           # Staging iOS
./scripts/build.sh development web       # Dev web build
./scripts/build.sh production appbundle  # Prod App Bundle
```

**What it does:**
- Loads environment from `.env.[environment]`
- Builds for specified platform
- Outputs build artifacts

**When to use:** Creating release builds

---

## Environment Files

Scripts read from these files:

```
.env.development    # Local development
.env.staging        # QA/staging environment
.env.production     # Production release
```

### Example .env.development
```bash
API_BASE_URL=https://dev-api.yourapp.com
APP_NAME=My App Dev
APP_ENV=development
ENABLE_LOGGING=true
ENABLE_ANALYTICS=false
```

### Accessing in Code

```dart
import 'package:template/core/config/env_config.dart';

// Use configuration
final apiUrl = EnvConfig.apiBaseUrl;
final isDev = EnvConfig.isDevelopment;

if (EnvConfig.enableLogging) {
  print('Logging enabled');
}
```

---

## Script Permissions

All scripts should be executable:

```bash
chmod +x scripts/*.sh
```

This is done automatically during setup, but if you get permission errors:

```bash
cd scripts
chmod +x setup.sh run.sh build.sh
```

---

## Platform-Specific Notes

### macOS/Linux
Scripts work out of the box. Use bash or zsh.

### Windows
Scripts are bash-based. Use one of:
- Git Bash (recommended)
- WSL (Windows Subsystem for Linux)
- Convert to PowerShell (manual)

---

## Troubleshooting

### "Command not found: flutter"
Ensure Flutter is in your PATH:
```bash
which flutter
# Should output: /path/to/flutter/bin/flutter
```

### "Permission denied"
Make scripts executable:
```bash
chmod +x scripts/*.sh
```

### Environment variables not loading
- Check `.env.[environment]` file exists
- Verify file format (no spaces around =)
- Check EnvConfig.dart has matching variables

### Build fails
- Run `flutter clean`
- Run `flutter pub get`
- Try building with Flutter directly:
  ```bash
  flutter build apk --dart-define-from-file=.env.production
  ```

---

## Customization

Scripts are customizable! Edit them to add:
- Pre-build steps
- Post-build notifications
- Custom environment variables
- Platform-specific configurations
- CI/CD integration

---

## Best Practices

1. **Never commit .env files** (they're in .gitignore)
2. **Use .env.example as template** for team members
3. **Keep production secrets secure** - use CI/CD secrets
4. **Test builds locally** before deploying
5. **Document custom variables** in .env.example

---

## Integration with CI/CD

### GitHub Actions
```yaml
- name: Run tests
  run: flutter test

- name: Build production APK
  run: ./scripts/build.sh production apk
  env:
    API_BASE_URL: ${{ secrets.API_BASE_URL_PROD }}
```

### GitLab CI
```yaml
build:
  script:
    - ./scripts/build.sh production apk
```

---

## Quick Reference

```bash
# First time setup
./scripts/setup.sh

# Daily development
./scripts/run.sh development

# Test staging
./scripts/run.sh staging

# Production build
./scripts/build.sh production apk

# Quick Flutter commands
flutter clean
flutter pub get
flutter test
flutter analyze
```

---

**Scripts designed for maximum productivity! 🚀**

# Quick Reference Card

## 🚀 One-Command Operations

### Setup New Project
```bash
./scripts/setup.sh
```
→ App name, bundle ID, API URL, environments configured

### Generate Feature
```bash
mason make feature --name [feature_name]
```
→ Complete MVC + routes + state + tests + build

### Run with Environment
```bash
./scripts/run.sh [development|staging|production]
```

### Build with Environment
```bash
./scripts/build.sh [environment] [apk|ios|web|...]
```

---

## 📂 What Gets Auto-Created

### When you run: `mason make feature --name profile`

```
Created automatically:
├── lib/features/profile/
│   ├── models/profile_models.dart         ✅ Freezed models
│   ├── controllers/profile_actions.dart   ✅ Redux CRUD actions
│   └── views/
│       ├── profile_screen.dart           ✅ UI
│       ├── profile_connector.dart        ✅ StoreConnector
│       └── profile_vm.dart               ✅ ViewModel

Updated automatically:
├── lib/core/store/
│   ├── app_state.dart                    ✅ ProfileState added
│   └── substates/profile_state.dart      ✅ Created
├── lib/core/router/app_router.dart       ✅ Route + extensions
├── lib/core/constants/app_constants.dart ✅ API endpoints
└── test/profile_test.dart                ✅ Unit tests

Generated automatically:
└── *.freezed.dart, *.g.dart              ✅ build_runner ran
```

---

## 🎯 Navigation

After `mason make feature --name profile`:

```dart
// Immediately available:
context.goToProfile();    // Navigate
context.pushProfile();    // Push

// Route URL:
// https://yourapp.com/profile
```

---

## 🌍 Environment Variables

### .env.development
```bash
API_BASE_URL=https://dev-api.yourapp.com
APP_ENV=development
ENABLE_LOGGING=true
```

### .env.production
```bash
API_BASE_URL=https://api.yourapp.com
APP_ENV=production
ENABLE_LOGGING=false
```

### Access in code:
```dart
EnvConfig.apiBaseUrl
EnvConfig.isDevelopment
EnvConfig.enableLogging
```

---

## ⚡ Quick Commands

```bash
# Code generation
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs

# Tests
flutter test

# Analyze
flutter analyze

# Clean
flutter clean && flutter pub get
```

---

## 📋 Feature Generation Checklist

What Mason does for you:

- [x] Create MVC structure
- [x] Add Freezed models
- [x] Create Redux actions
- [x] Build UI components
- [x] Create state file
- [x] Update AppState
- [x] Register routes
- [x] Add navigation methods
- [x] Add API endpoints
- [x] Generate tests
- [x] Run build_runner
- [x] ✨ Everything compiles!

What you do:

- [ ] Customize models
- [ ] Implement UI
- [ ] Write business logic
- [ ] Ship features! 🚀

---

## 🎨 File Naming Conventions

- Features: `snake_case` (user_profile)
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Actions: `VerbNounAction`
- Routes: `/kebab-case`
- Methods: `camelCase()`

---

## 💡 Pro Tips

1. **Always use Mason for features** - It's faster and error-free
2. **Use environment scripts** - `./scripts/run.sh development`
3. **Let build_runner run** - Mason does it automatically
4. **Check generated tests** - They're a great starting point
5. **Review DEVELOPMENT.md** - Comprehensive dev guide

---

## 🆘 Troubleshooting

### Routes not working?
Check `lib/core/router/app_router.dart` for the route

### State not updating?
Verify `AppState` includes your feature state

### Build errors?
Run: `dart run build_runner build --delete-conflicting-outputs`

### Need help?
See: `DEVELOPMENT.md` for detailed guide

---

**Keep this card handy! 📌**

# Hive Integration - Summary of Changes

## 🎯 What Was Added

### 1. Dependencies (pubspec.yaml)
- ✅ `hive: ^2.2.3` - Core Hive database
- ✅ `hive_flutter: ^1.1.0` - Flutter integration
- ✅ `path_provider: ^2.1.4` - File system paths
- ✅ `hive_generator: ^2.0.1` (dev) - Code generation
- ⚠️ `freezed: ^2.5.2` (downgraded from ^2.5.7 due to dependency conflict)

### 2. Core Services

**[lib/core/services/hive_service.dart](lib/core/services/hive_service.dart)** - New file
- Singleton service for Hive operations
- Methods: `init()`, `openBox()`, `closeBox()`, `deleteBox()`, `registerAdapter()`
- Platform-aware initialization (iOS/Android/Desktop/Web)
- Box management utilities

### 3. Initialization

**[lib/main_common.dart](lib/main_common.dart)** - Updated
```dart
// Added Hive initialization before StorageHelper
await HiveService().init();
```

### 4. Mason Brick Updates

**[bricks/feature/brick.yaml](bricks/feature/brick.yaml)** - Updated
```yaml
hive_type_id:
  type: number
  description: Unique Hive type ID (must be unique, use 100+)
  prompt: Enter a unique Hive type ID (use 100+)
  default: 100
```

**[bricks/feature/__brick__/models/{{name}}_models.dart](bricks/feature/__brick__/lib/features/{{name.snakeCase()}}/models/{{name.snakeCase()}}_models.dart)** - Updated
- Added `import 'package:hive/hive.dart';`
- Added `@HiveType(typeId: {{hive_type_id}})` annotation to models
- Added `@HiveField(N)` annotations to all model fields

**[bricks/feature/__brick__/controllers/{{name}}_actions.dart](bricks/feature/__brick__/lib/features/{{name.snakeCase()}}/controllers/{{name.snakeCase()}}_actions.dart)** - Updated
- Added Hive box name constant: `const String _{{name.camelCase()}}BoxName = '{{name.snakeCase()}}_box';`
- Fetch action: Tries API first, falls back to Hive cache on failure
- Create action: Syncs to both API and Hive
- Update action: Syncs to both API and Hive
- Delete action: Syncs to both API and Hive
- Local-only actions (when has_api=false): Directly operate on Hive

**[bricks/feature/hooks/post_gen.dart](bricks/feature/hooks/post_gen.dart)** - Updated
- New function: `_registerHiveAdapter()` - Registers adapter in main_common.dart
- Adds model import to main_common.dart
- Registers `{FeatureName}Adapter()` after HiveService initialization
- Updated task list to show "Run the app to test Hive integration!"

### 5. Documentation

**[HIVE_INTEGRATION.md](HIVE_INTEGRATION.md)** - New file
- Comprehensive guide to Hive integration
- Offline-first architecture explanation
- CRUD patterns and examples
- Best practices and troubleshooting
- Migration guide from SharedPreferences/SQLite

**[.github/copilot-instructions.md](.github/copilot-instructions.md)** - Updated
- Added "Local Database: Hive" section to Core Patterns
- Added "Hive Database Pattern" section with type IDs and usage
- Updated Mason automation checklist to include Hive
- Added HiveService to key files reference
- Updated common pitfalls to mention Hive/build_runner

## 🔄 Automation Flow

When you run `mason make feature --name products`:

1. **Mason prompts for Hive type ID** (default: 100)
2. **Generates model** with `@HiveType` and `@HiveField` annotations
3. **Generates actions** with Hive caching/syncing logic
4. **post_gen hook runs**:
   - Registers route in app_router.dart
   - Creates state file
   - Updates AppState
   - **Registers Hive adapter in main_common.dart** ⭐ NEW
   - Updates API endpoints (if has_api=true)
   - Runs build_runner (generates Hive adapter)
5. **Ready to use!** - Offline-first CRUD operations work out of the box

## 📊 Architecture Pattern

### Offline-First Flow

```
User Action
    ↓
Fetch Action Dispatched
    ↓
Try API Call
    ├─ Success → Cache in Hive → Update State
    └─ Failure → Load from Hive Cache → Update State
                    ↓
                If Cache Empty → Show Error
```

### Create/Update/Delete Flow

```
User Action
    ↓
CUD Action Dispatched
    ↓
API Call
    ├─ Success → Sync to Hive → Update State
    └─ Failure → Show Error (don't update Hive)
```

## 🔧 What You Need to Know

### Hive Type IDs
- Each model needs a unique `typeId` (100+)
- Mason prompts for this during generation
- Track your IDs to avoid conflicts:
  ```dart
  @HiveType(typeId: 100)  // Products
  @HiveType(typeId: 101)  // Categories
  @HiveType(typeId: 102)  // Orders
  ```

### Box Naming Convention
- Each feature gets its own box: `{feature_name}_box`
- Example: `products_box`, `orders_box`, `categories_box`

### Generated Adapter
- Build_runner creates `{ModelName}Adapter` class
- Automatically registered in main_common.dart by Mason hook
- Located in: `lib/features/{feature}/models/{feature}_models.g.dart`

## ✅ Testing Offline Mode

1. Generate a feature: `mason make feature --name products`
2. Run the app
3. Fetch data (gets cached in Hive)
4. Turn off network/API
5. Fetch again → Should load from Hive cache
6. CRUD operations work offline (if has_api=false)

## 🚀 Example Generated Code

**Model:**
```dart
@freezed
@HiveType(typeId: 100)
class Product with _$Product {
  const factory Product({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required double price,
  }) = _Product;
}
```

**Fetch Action:**
```dart
class FetchProductsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      // Try API
      final response = await apiService.get('/products');
      if (response.success) {
        await _cacheItems(items);  // Cache in Hive
        return state.copyWith(products: items);
      }
      
      // Fallback to cache
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(products: cachedItems);
      }
    } catch (e) {
      // Error fallback
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(products: cachedItems);
      }
    }
  }
}
```

**Main Common (auto-updated by Mason):**
```dart
import 'features/products/models/products_models.dart';

void mainCommon(AppFlavor flavor) async {
  await HiveService().init();
  
  // Register Hive adapters
  HiveService().registerAdapter(ProductAdapter());
  // ... more adapters added by Mason
}
```

## 📝 Updated Commands

No new commands needed! Everything is automated:

```bash
# Generate feature with Hive support (fully automated)
mason make feature --name products

# Run app (Hive initialized automatically)
flutter run

# Build runner (Mason runs this automatically)
dart run build_runner build --delete-conflicting-outputs
```

## 🎁 Benefits

1. **Zero Configuration** - Mason handles everything
2. **Offline-First** - Apps work without internet
3. **Fast Performance** - Hive is extremely fast (~1M ops/sec)
4. **Type-Safe** - Full Dart type safety with Freezed
5. **Automatic Caching** - No manual cache management
6. **Fallback Support** - Graceful degradation when API fails
7. **Developer Experience** - No boilerplate code needed

## ⚠️ Breaking Changes

None! This is a backward-compatible addition. Existing features continue to work without Hive.

To add Hive to existing features:
1. Add `@HiveType(typeId: X)` to model
2. Add `@HiveField(N)` to each field
3. Update actions to include Hive caching
4. Register adapter in main_common.dart
5. Run build_runner

Or simply regenerate the feature with Mason and port your custom code.

## 📚 Resources

- [HIVE_INTEGRATION.md](HIVE_INTEGRATION.md) - Detailed guide
- [lib/core/services/hive_service.dart](lib/core/services/hive_service.dart) - Service implementation
- [Hive Documentation](https://docs.hivedb.dev/) - Official docs
- [.github/copilot-instructions.md](.github/copilot-instructions.md) - AI agent guide

---

**Ready to use!** Generate a feature with `mason make feature` and enjoy offline-first data persistence! 🚀

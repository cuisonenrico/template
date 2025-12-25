# Hive Database Integration

## Overview

This template now includes **Hive**, a fast and lightweight NoSQL database for Flutter applications. Hive provides offline-first data persistence with automatic caching and synchronization.

## Features

✅ **Offline-First Architecture** - All data is cached locally first  
✅ **Automatic Cache Sync** - API responses are automatically cached  
✅ **Type-Safe Models** - Full type safety with Freezed and Hive adapters  
✅ **Zero Manual Configuration** - Mason brick handles everything  
✅ **Fallback Support** - Loads from cache when API fails  
✅ **CRUD Operations** - Create, Read, Update, Delete with automatic caching

## How It Works

### 1. Database Service

The [HiveService](lib/core/services/hive_service.dart) singleton provides a clean API for Hive operations:

```dart
// Open a box
final box = await HiveService().openBox<YourModel>('your_box');

// Basic operations
await box.add(item);              // Create
final items = box.values.toList(); // Read all
await box.putAt(index, item);     // Update
await box.deleteAt(index);        // Delete
await box.clear();                // Clear all data
```

### 2. Automatic Integration with Mason

When you generate a feature using Mason:

```bash
mason make feature --name products
```

The brick automatically:
1. **Adds Hive annotations** to your model (`@HiveType`, `@HiveField`)
2. **Creates CRUD actions** with automatic Hive caching
3. **Registers Hive adapter** in `main_common.dart`
4. **Generates Hive adapter** via build_runner
5. **Creates feature box** named `{feature_name}_box`

### 3. Hive Type IDs

Each model needs a unique `typeId` for Hive serialization:

- **Range 0-99**: Reserved for Flutter/Hive internal use
- **Range 100+**: Available for your models
- **Mason prompts** for typeId during feature generation
- **Track your IDs** to avoid conflicts across features

Example:
```dart
@HiveType(typeId: 100)  // Products
@HiveType(typeId: 101)  // Categories  
@HiveType(typeId: 102)  // Orders
```

### 4. Model Structure

Generated models include Hive annotations:

```dart
@freezed
@HiveType(typeId: 100)
class Product with _$Product {
  const factory Product({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required double price,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}
```

### 5. Offline-First CRUD Pattern

All actions follow an offline-first pattern:

**Fetch (with fallback):**
```dart
class FetchProductsAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    try {
      // 1. Try API first
      final response = await apiService.get('/products');
      if (response.success) {
        final items = parseItems(response.data);
        await _cacheItems(items);  // Cache in Hive
        return state.copyWith(products: items);
      }
      
      // 2. Fallback to Hive cache
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(products: cachedItems);
      }
    } catch (e) {
      // 3. On error, try cache again
      final cachedItems = await _loadFromCache();
      if (cachedItems.isNotEmpty) {
        return state.copyWith(products: cachedItems);
      }
    }
  }
}
```

**Create/Update/Delete:**
```dart
class CreateProductAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    // 1. Send to API
    final response = await apiService.post('/products', product.toJson());
    
    if (response.success) {
      final newProduct = Product.fromJson(response.data);
      
      // 2. Add to Hive
      await _addToCache(newProduct);
      
      // 3. Update state
      return state.copyWith(products: [...state.products, newProduct]);
    }
  }
}
```

## Initialization Flow

1. **App startup** ([main_common.dart](lib/main_common.dart)):
   ```dart
   await HiveService().init();  // Initialize Hive
   ```

2. **Adapter registration** (automatic via Mason):
   ```dart
   HiveService().registerAdapter(ProductAdapter());
   ```

3. **Box creation** (lazy, on first access):
   ```dart
   final box = await HiveService().openBox<Product>('products_box');
   ```

## Working with Hive Boxes

### Open a Box

```dart
final box = await HiveService().openBox<Product>('products_box');
```

### Read Data

```dart
// Get all items
final allProducts = box.values.toList();

// Get single item by index
final product = box.getAt(0);

// Get item by key (if using put with key)
final product = box.get('product_id');

// Check if box has data
final hasData = await HiveService().hasData('products_box');
```

### Write Data

```dart
// Add new item (auto-incremented key)
await box.add(product);

// Put with specific key
await box.put('product_id', product);

// Update at index
await box.putAt(index, updatedProduct);

// Add multiple items
await box.addAll([product1, product2, product3]);
```

### Delete Data

```dart
// Delete at index
await box.deleteAt(0);

// Delete by key
await box.delete('product_id');

// Clear all data
await box.clear();

// Delete entire box
await HiveService().deleteBox('products_box');
```

## Best Practices

### 1. Always Handle Cache Loading

```dart
Future<List<Product>> _loadFromCache() async {
  try {
    final box = await HiveService().openBox<Product>('products_box');
    return box.values.toList();
  } catch (e) {
    return [];  // Return empty list on error
  }
}
```

### 2. Ignore Cache Errors

```dart
Future<void> _cacheItems(List<Product> items) async {
  try {
    final box = await HiveService().openBox<Product>('products_box');
    await box.clear();
    for (final item in items) {
      await box.add(item);
    }
  } catch (e) {
    // Ignore cache errors - don't block main flow
  }
}
```

### 3. Use Unique Type IDs

Keep track of used type IDs to avoid conflicts:

```dart
// ✅ Good
@HiveType(typeId: 100)  // Product
@HiveType(typeId: 101)  // Category
@HiveType(typeId: 102)  // Order

// ❌ Bad - Duplicate IDs
@HiveType(typeId: 100)  // Product
@HiveType(typeId: 100)  // Category  // CONFLICT!
```

### 4. Clean Cache When Needed

```dart
// Clear cache on logout
class LogoutAction extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async {
    await HiveService().clearBox('products_box');
    await HiveService().clearBox('orders_box');
    // ... clear other boxes
  }
}
```

### 5. Test Cache Fallback

```dart
// Disable network to test offline mode
await toggleNetworkConnection(false);
dispatch(FetchProductsAction());  // Should load from cache
```

## Performance Considerations

- **Hive is Fast**: ~1M reads/writes per second
- **Lazy Loading**: Boxes are opened only when needed
- **Efficient Updates**: Only changed items are written
- **Background Operations**: All Hive operations are async

## Troubleshooting

### Issue: "Type is not registered"

**Solution**: Make sure the Hive adapter is registered in [main_common.dart](lib/main_common.dart):

```dart
HiveService().registerAdapter(YourModelAdapter());
```

### Issue: "Box is already open"

**Solution**: Use `HiveService().openBox()` which handles this automatically:

```dart
// ✅ Good - handles already open boxes
final box = await HiveService().openBox<Product>('products_box');

// ❌ Bad - may throw error
final box = await Hive.openBox<Product>('products_box');
```

### Issue: "Cannot find generated adapter"

**Solution**: Run build_runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Mason brick does this automatically, but you may need to run it manually after modifying models.

### Issue: Type ID conflicts

**Solution**: Change the typeId to a unique value:

```dart
// Before
@HiveType(typeId: 100)  // Conflict with another model

// After  
@HiveType(typeId: 105)  // Unique ID
```

Then run build_runner again.

## Migration Guide

### From SharedPreferences

**Before:**
```dart
final prefs = await SharedPreferences.getInstance();
final json = prefs.getString('products');
final products = jsonDecode(json);
```

**After (with Hive):**
```dart
final box = await HiveService().openBox<Product>('products_box');
final products = box.values.toList();
```

### From SQLite

Hive is a great alternative to SQLite for most use cases:

| Feature | SQLite | Hive |
|---------|--------|------|
| Setup | Complex | Simple |
| Performance | Fast | Faster |
| Type Safety | Manual | Automatic |
| Queries | SQL | Dart filters |
| Relations | Built-in | Manual |

## Related Files

- [lib/core/services/hive_service.dart](lib/core/services/hive_service.dart) - Hive service singleton
- [lib/main_common.dart](lib/main_common.dart) - Hive initialization
- [bricks/feature/](bricks/feature/) - Mason brick templates
- [bricks/feature/hooks/post_gen.dart](bricks/feature/hooks/post_gen.dart) - Hive adapter registration

## Next Steps

1. ✅ Hive is now integrated - no manual setup needed!
2. ✅ Use `mason make feature` to generate new features
3. ✅ Models automatically include Hive annotations
4. ✅ CRUD actions automatically cache in Hive
5. 🎯 Test offline mode by disabling network
6. 🎯 Monitor cache usage via Hive box methods

## Resources

- [Hive Documentation](https://docs.hivedb.dev/)
- [Hive GitHub](https://github.com/isar/hive)
- [Flutter Offline-First Guide](https://flutter.dev/docs/cookbook/persistence)

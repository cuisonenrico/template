import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/app_logger.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  final _logger = AppLogger();
  bool _initialized = false;

  /// Initialize Hive database
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize Hive with app directory
      if (Platform.isIOS || Platform.isAndroid) {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(appDocumentDir.path);
        _logger.database(
          'Initialized',
          'Hive',
          data: {'path': appDocumentDir.path},
        );
      } else {
        await Hive.initFlutter();
        _logger.database('Initialized', 'Hive');
      }

      _initialized = true;
    } catch (e, stackTrace) {
      _logger.error('Failed to initialize Hive', e, stackTrace);
      rethrow;
    }
  }

  /// Open a box (table)
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!_initialized) {
      await init();
    }

    try {
      if (Hive.isBoxOpen(boxName)) {
        _logger.database('Box already open', boxName);
        return Hive.box<T>(boxName);
      }

      _logger.database('Opening box', boxName);
      final box = await Hive.openBox<T>(boxName);
      _logger.database('Box opened', boxName, data: {'items': box.length});
      return box;
    } catch (e, stackTrace) {
      _logger.error('Failed to open box: $boxName', e, stackTrace);
      rethrow;
    }
  }

  /// Close a specific box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
      _logger.database('Box closed', boxName);
    }
  }

  /// Close all boxes
  Future<void> closeAll() async {
    await Hive.close();
  }

  /// Delete a box
  Future<void> deleteBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).deleteFromDisk();
      } else {
        await Hive.deleteBoxFromDisk(boxName);
      }
      _logger.database('Box deleted', boxName);
    } catch (e, stackTrace) {
      _logger.error('Failed to delete box: $boxName', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all data from a box
  Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    final itemCount = box.length;
    await box.clear();
    _logger.database(
      'Box cleared',
      boxName,
      data: {'items_removed': itemCount},
    );
  }

  /// Check if box exists and has data
  Future<bool> hasData(String boxName) async {
    try {
      final box = await openBox(boxName);
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get box size
  Future<int> getBoxSize(String boxName) async {
    final box = await openBox(boxName);
    return box.length;
  }

  /// Register adapter
  void registerAdapter<T>(TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }
}

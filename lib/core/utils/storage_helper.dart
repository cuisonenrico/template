import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';

class StorageHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Token Management
  static Future<void> saveAccessToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.accessTokenKey, token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.accessTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.refreshTokenKey, token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  // User Data Management
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.userDataKey, json.encode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _instance;
    final userDataString = prefs.getString(AppConstants.userDataKey);
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Login State Management
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _instance;
    await prefs.setBool(AppConstants.isLoggedInKey, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  // Generic Methods
  static Future<void> saveString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await _instance;
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  static Future<void> saveDouble(String key, double value) async {
    final prefs = await _instance;
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await _instance;
    return prefs.getDouble(key);
  }

  // Theme Management
  static Future<void> saveThemeMode(AppThemeMode themeMode) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.themeModeKey, themeMode.name);
  }

  static Future<AppThemeMode> getThemeMode() async {
    final prefs = await _instance;
    final themeModeString = prefs.getString(AppConstants.themeModeKey);

    if (themeModeString != null) {
      return AppThemeMode.values.firstWhere((mode) => mode.name == themeModeString, orElse: () => AppThemeMode.system);
    }

    return AppThemeMode.system;
  }

  // Clear Methods
  static Future<void> clearUserSession() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.userDataKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
  }

  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }

  static Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }

  // Get all keys
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized offline storage service wrapping [SharedPreferences].
/// Provides safe asynchronous access and persistence with in-memory fallback.
class StorageService {
  static final StorageService instance = StorageService._internal();

  StorageService._internal();

  SharedPreferences? _prefs;
  final Map<String, dynamic> _memoryCache = {};

  /// Initializes the underlying [SharedPreferences] instance.
  /// An optional [mockPrefs] can be supplied for unit testing.
  Future<void> init([SharedPreferences? mockPrefs]) async {
    if (mockPrefs != null) {
      _prefs = mockPrefs;
      return;
    }
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('StorageService initialization fallback: $e');
    }
  }

  Future<SharedPreferences?> get _safePrefs async {
    if (_prefs != null) return _prefs;
    try {
      _prefs = await SharedPreferences.getInstance();
      return _prefs;
    } catch (_) {
      return null;
    }
  }

  /// Retrieves a string value.
  Future<String?> getString(String key) async {
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return prefs.getString(key);
      }
    } catch (_) {}
    return _memoryCache[key] as String?;
  }

  /// Sets a string value.
  Future<bool> setString(String key, String value) async {
    _memoryCache[key] = value;
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return await prefs.setString(key, value);
      }
    } catch (_) {}
    return true;
  }

  /// Retrieves a list of strings (e.g. JSON strings).
  Future<List<String>?> getStringList(String key) async {
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return prefs.getStringList(key);
      }
    } catch (_) {}
    final cached = _memoryCache[key];
    if (cached is List) {
      return List<String>.from(cached);
    }
    return null;
  }

  /// Persists a list of strings.
  Future<bool> setStringList(String key, List<String> value) async {
    _memoryCache[key] = List<String>.from(value);
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return await prefs.setStringList(key, value);
      }
    } catch (_) {}
    return true;
  }

  /// Retrieves a boolean value.
  Future<bool?> getBool(String key) async {
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return prefs.getBool(key);
      }
    } catch (_) {}
    return _memoryCache[key] as bool?;
  }

  /// Sets a boolean value.
  Future<bool> setBool(String key, bool value) async {
    _memoryCache[key] = value;
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return await prefs.setBool(key, value);
      }
    } catch (_) {}
    return true;
  }

  /// Removes a stored key.
  Future<bool> remove(String key) async {
    _memoryCache.remove(key);
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return await prefs.remove(key);
      }
    } catch (_) {}
    return true;
  }

  /// Clears all stored keys.
  Future<bool> clear() async {
    _memoryCache.clear();
    try {
      final prefs = await _safePrefs;
      if (prefs != null) {
        return await prefs.clear();
      }
    } catch (_) {}
    return true;
  }
}

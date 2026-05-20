import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static Box? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('fame_x_box');
  }

  // Generic Save and Retrieve from Hive Box
  static String getString(String key, {String defaultValue = ''}) {
    return _box?.get(key) ?? defaultValue;
  }

  static Future<void> setString(String key, String value) async {
    await _box?.put(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _box?.get(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    await _box?.put(key, value);
  }

  static int getInt(String key, {int defaultValue = 1}) {
    return _box?.get(key) ?? defaultValue;
  }

  static Future<void> setInt(String key, int value) async {
    await _box?.put(key, value);
  }

  // String List helpers using Hive lists
  static List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    final list = _box?.get(key);
    if (list is List) {
      return list.map((e) => e.toString()).toList();
    }
    return defaultValue;
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _box?.put(key, value);
  }

  // Clear helper
  static Future<void> clearAll() async {
    await _box?.clear();
  }
}

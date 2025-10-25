import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static SharedPreferences? _sharedPreferences;

  // Private constructor
  CacheHelper._();

  // Factory constructor to initialize SharedPreferences
  static Future<CacheHelper> create() async {
    final cacheHelper = CacheHelper._();
    await cacheHelper.init();
    return cacheHelper;
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // Helper to ensure sharedPreferences is not null
  SharedPreferences get _prefs {
    if (_sharedPreferences == null) {
      throw Exception('SharedPreferences not initialized');
    }
    return _sharedPreferences!;
  }

  String? getDataString({required String key}) {
    return _prefs.getString(key);
  }

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await _prefs.setBool(key, value);
    }
    if (value is String) {
      return await _prefs.setString(key, value);
    }
    if (value is int) {
      return await _prefs.setInt(key, value);
    }
    return await _prefs.setDouble(key, value);
  }

  dynamic getData({required String key}) {
    return _prefs.get(key);
  }

  Future<bool> removeData({required String key}) async {
    return await _prefs.remove(key);
  }

  Future<bool> containsKey({required String key}) async {
    return _prefs.containsKey(key);
  }

  Future<bool> clearData() async {
    return await _prefs.clear();
  }

  Future<dynamic> put({required String key, required dynamic value}) async {
    if (value is String) {
      return await _prefs.setString(key, value);
    } else if (value is bool) {
      return await _prefs.setBool(key, value);
    } else {
      return await _prefs.setInt(key, value);
    }
  }
}
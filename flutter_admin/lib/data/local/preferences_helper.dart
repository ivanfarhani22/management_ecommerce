import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static final PreferencesHelper instance = PreferencesHelper._init();
  late SharedPreferences _prefs;

  PreferencesHelper._init();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // String methods
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  // Boolean methods
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  // Double methods
  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  // Integer methods
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  // List of strings methods
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  // Remove a specific key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  // Clear all preferences
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Check if a key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }
}
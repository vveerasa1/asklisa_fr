import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static SharedPreferences? _prefs;

  static clearAll(){
    _prefs?.clear();
  }
  static Future<SharedPreferences> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs ?? await SharedPreferences.getInstance();
  }

  static setString(String key, String value) async {
    return await _prefs?.setString(key, value);
  }

  static getString(String key)  {
    return _prefs?.getString(key) ?? '';
  }

  static setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value);
  }

  static getBool(String key)  {
    return _prefs?.getBool(key) ?? false;
  }
  static setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value);
  }

  static getStringList(String key) async {
    return  _prefs?.getStringList(key);
  }

  static setMap(String key, Map<String, dynamic> value) async {
    String jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  static Map<String, dynamic> getMap(String key) {
    String jsonString = getString(key);
    if (jsonString.isEmpty) return {};
    return jsonDecode(jsonString);
  }
}

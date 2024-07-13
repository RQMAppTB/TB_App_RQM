import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class DataManagement{
  static final DataManagement _singleton = DataManagement._internal();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  factory DataManagement() {
    return _singleton;
  }

  DataManagement._internal();

  Future<bool> saveInt(String name, int value) async {
    // Save the data in the shared preferences
    final SharedPreferences prefs = await _prefs;

    var test = prefs.setInt(name, value);
    return test;
  }

  Future<int?> getInt(String name) async {
    // Get the data from the shared preferences
    final SharedPreferences prefs = await _prefs;

    var test = prefs.getInt(name);
    return test;
  }

  Future<bool> saveString(String name, String value) async {
    // Save the data in the shared preferences
    final SharedPreferences prefs = await _prefs;

    var test = prefs.setString(name, value);
    return test;
  }

  Future<String> getString(String name) async {
    // Get the data from the shared preferences
    final SharedPreferences prefs = await _prefs;

    var test = prefs.getString(name);
    return test ?? "";
  }

  Future<bool> removeData(String name) async {
    // Remove the data from the shared preferences
    final SharedPreferences prefs = await _prefs;

    var test = prefs.remove(name);
    return test;
  }

  Future<bool> doesDataExist(String name) async {
    // Check if the data exists in the shared preferences
    final SharedPreferences prefs = await _prefs;

    var test = prefs.containsKey(name);
    log('doesDataExist: $test');
    return test;
  }
}
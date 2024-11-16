import 'DataManagement.dart';

/// Class to manage the name of the user.
class NameData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the name [name] of the user in the shared preferences.
  static Future<bool> saveName(String name) async {
    return _dataManagement.saveString('name', name);
  }

  /// Get the name of the user from the shared preferences.
  static Future<String> getName() async {
    return _dataManagement.getString('name');
  }

  /// Remove the name of the user from the shared preferences.
  static Future<bool> removeName() async {
    return _dataManagement.removeData('name');
  }

  /// Check if the name of the user exists in the shared preferences.
  static Future<bool> doesNameExist() async {
    return _dataManagement.doesDataExist('name');
  }
}

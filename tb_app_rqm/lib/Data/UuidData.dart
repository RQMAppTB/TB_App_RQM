import 'DataManagement.dart';

/// Class to manage the UUID of the user.
class UuidData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the UUID [uuid] of the user in the shared preferences.
  static Future<bool> saveUuid(String uuid) async {
    return _dataManagement.saveString('uuid', uuid);
  }

  /// Get the UUID of the user from the shared preferences.
  static Future<String> getUuid() async {
    return _dataManagement.getString('uuid');
  }

  /// Remove the UUID of the user from the shared preferences.
  static Future<bool> removeUuid() async {
    return _dataManagement.removeData('uuid');
  }

  /// Check if the UUID of the user exists in the shared preferences.
  static Future<bool> doesUuidExist() async {
    return _dataManagement.doesDataExist('uuid');
  }
}

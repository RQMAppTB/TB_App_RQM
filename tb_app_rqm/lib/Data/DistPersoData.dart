import 'DataManagement.dart';

/// Class to manage the distance traveled by the user.
class DistPersoData{

  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the distance [distPerso] traveled by the user in the shared preferences.
  static Future<bool> saveDistPerso(int distPerso) async {
    return _dataManagement.saveInt('distPerso', distPerso);
  }

  /// Get the distance traveled by the user from the shared preferences.
  static Future<int?> getDistPerso() async {
    return _dataManagement.getInt('distPerso');
  }

  /// Remove the distance traveled by the user from the shared preferences.
  static Future<bool> removeDistPerso() async {
    return _dataManagement.removeData('distPerso');
  }

  /// Check if the distance traveled by the user exists in the shared preferences.
  static Future<bool> doesDistPersoExist() async {
    return _dataManagement.doesDataExist('distPerso');
  }
}
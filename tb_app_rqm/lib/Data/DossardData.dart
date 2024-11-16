import 'DataManagement.dart';

/// Class to manage the dossard number.
class DossardData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the dossard number [dossard] in the shared preferences.
  static Future<bool> saveDossard(int dossard) async {
    return _dataManagement.saveInt('dossard', dossard);
  }

  /// Get the dossard number from the shared preferences.
  static Future<int?> getDossard() async {
    return _dataManagement.getInt('dossard');
  }

  /// Remove the dossard number from the shared preferences.
  static Future<bool> removeDossard() async {
    return _dataManagement.removeData('dossard');
  }

  /// Check if the dossard number exists in the shared preferences.
  static Future<bool> doesDossardExist() async {
    return _dataManagement.doesDataExist('dossard');
  }
}

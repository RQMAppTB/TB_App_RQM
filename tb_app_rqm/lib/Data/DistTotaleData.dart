import 'DataManagement.dart';

/// Class to manage the total distance all the participants.
class DistTotaleData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the total distance [distTotale] traveled by all the participants in
  /// the shared preferences.
  static Future<bool> saveDistTotale(int distTotale) async {
    return _dataManagement.saveInt('distTotale', distTotale);
  }

  /// Get the total distance traveled by all the participants from the shared preferences.
  static Future<int?> getDistTotale() async {
    return _dataManagement.getInt('distTotale');
  }

  /// Remove the total distance traveled by all the participants from the shared preferences.
  static Future<bool> removeDistTotale() async {
    return _dataManagement.removeData('distTotale');
  }

  /// Check if the total distance traveled by all the participants exists in the shared preferences.
  static Future<bool> doesDistTotaleExist() async {
    return _dataManagement.doesDataExist('distTotale');
  }
}

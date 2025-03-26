import 'DataManagement.dart';

/// Class to manage the number of participants.
class ContributorsData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the number of contributors [contributors] in the shared preferences.
  static Future<bool> saveContributors(int contributors) async {
    return _dataManagement.saveInt('contributors', contributors);
  }

  /// Get the number of contributors from the shared preferences.
  static Future<int?> getContributors() async {
    return _dataManagement.getInt('contributors');
  }

  /// Remove the number of contributors from the shared preferences.
  static Future<bool> removeContributors() async {
    return _dataManagement.removeData('contributors');
  }

  /// Check if the number of contributors exists in the shared preferences.
  static Future<bool> doesContributorsExist() async {
    return _dataManagement.doesDataExist('contributors');
  }
}

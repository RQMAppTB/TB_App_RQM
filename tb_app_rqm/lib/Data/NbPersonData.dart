import 'DataManagement.dart';

/// Class to manage the number of participants.
class NbPersonData {

  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the number of participants [nbPerson] in the shared preferences.
  static Future<bool> saveNbPerson(int nbPerson) async {
    return _dataManagement.saveInt('nbPerson', nbPerson);
  }

  /// Get the number of participants from the shared preferences.
  static Future<int?> getNbPerson() async {
    return _dataManagement.getInt('nbPerson');
  }

  /// Remove the number of participants from the shared preferences.
  static Future<bool> removeNbPerson() async {
    return _dataManagement.removeData('nbPerson');
  }

  /// Check if the number of participants exists in the shared preferences.
  static Future<bool> doesNbPersonExist() async {
    return _dataManagement.doesDataExist('nbPerson');
  }
}
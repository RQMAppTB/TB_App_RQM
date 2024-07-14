import 'DataManagement.dart';

class NbPersonData {
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveNbPerson(int nbPerson) async {
    return _dataManagement.saveInt('nbPerson', nbPerson);
  }

  static Future<int?> getNbPerson() async {
    return _dataManagement.getInt('nbPerson');
  }

  static Future<bool> removeNbPerson() async {
    return _dataManagement.removeData('nbPerson');
  }

  static Future<bool> doesNbPersonExist() async {
    return _dataManagement.doesDataExist('nbPerson');
  }
}
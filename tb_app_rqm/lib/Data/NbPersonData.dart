import 'DataManagement.dart';

class NbPersonData {
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveNbPerson(int nbPerson) async {
    return _dataManagement.saveInt('nbPerson', nbPerson);
  }

  Future<int?> getNbPerson() async {
    return _dataManagement.getInt('nbPerson');
  }

  Future<bool> removeNbPerson() async {
    return _dataManagement.removeData('nbPerson');
  }

  Future<bool> doesNbPersonExist() async {
    return _dataManagement.doesDataExist('nbPerson');
  }
}
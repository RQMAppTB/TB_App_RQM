import 'DataManagement.dart';

class DossardData{
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveDossard(int dossard) async {
    return _dataManagement.saveInt('dossard', dossard);
  }

  Future<int?> getDossard() async {
    return _dataManagement.getInt('dossard');
  }

  Future<bool> removeDossard() async {
    return _dataManagement.removeData('dossard');
  }

  Future<bool> doesDossardExist() async {
    return _dataManagement.doesDataExist('dossard');
  }
}
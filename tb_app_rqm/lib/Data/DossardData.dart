import 'DataManagement.dart';

class DossardData{
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveDossard(int dossard) async {
    return _dataManagement.saveInt('dossard', dossard);
  }

  static Future<int?> getDossard() async {
    return _dataManagement.getInt('dossard');
  }

  static Future<bool> removeDossard() async {
    return _dataManagement.removeData('dossard');
  }

  static Future<bool> doesDossardExist() async {
    return _dataManagement.doesDataExist('dossard');
  }
}
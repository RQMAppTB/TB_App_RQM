import 'DataManagement.dart';

class DistPersoData{
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveDistPerso(int distPerso) async {
    return _dataManagement.saveInt('distPerso', distPerso);
  }

  static Future<int?> getDistPerso() async {
    return _dataManagement.getInt('distPerso');
  }

  static Future<bool> removeDistPerso() async {
    return _dataManagement.removeData('distPerso');
  }

  static Future<bool> doesDistPersoExist() async {
    return _dataManagement.doesDataExist('distPerso');
  }
}
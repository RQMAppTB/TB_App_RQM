import 'DataManagement.dart';

class DistTotaleData{
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveDistTotale(int distTotale) async {
    return _dataManagement.saveInt('distTotale', distTotale);
  }

  static Future<int?> getDistTotale() async {
    return _dataManagement.getInt('distTotale');
  }

  static Future<bool> removeDistTotale() async {
    return _dataManagement.removeData('distTotale');
  }

  static Future<bool> doesDistTotaleExist() async {
    return _dataManagement.doesDataExist('distTotale');
  }
}
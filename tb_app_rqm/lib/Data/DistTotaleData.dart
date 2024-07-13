import 'DataManagement.dart';

class DistTotaleData{
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveDistTotale(int distTotale) async {
    return _dataManagement.saveInt('distTotale', distTotale);
  }

  Future<int?> getDistTotale() async {
    return _dataManagement.getInt('distTotale');
  }

  Future<bool> removeDistTotale() async {
    return _dataManagement.removeData('distTotale');
  }

  Future<bool> doesDistTotaleExist() async {
    return _dataManagement.doesDataExist('distTotale');
  }
}
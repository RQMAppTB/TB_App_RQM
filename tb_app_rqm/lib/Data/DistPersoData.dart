import 'DataManagement.dart';

class DistPersoData{
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveDistPerso(int distPerso) async {
    return _dataManagement.saveInt('distPerso', distPerso);
  }

  Future<int?> getDistPerso() async {
    return _dataManagement.getInt('distPerso');
  }

  Future<bool> removeDistPerso() async {
    return _dataManagement.removeData('distPerso');
  }

  Future<bool> doesDistPersoExist() async {
    return _dataManagement.doesDataExist('distPerso');
  }
}
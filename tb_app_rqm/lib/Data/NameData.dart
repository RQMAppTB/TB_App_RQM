import 'DataManagement.dart';

class NameData{
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveName(String name) async {
    return _dataManagement.saveString('name', name);
  }

  Future<String> getName() async {
    return _dataManagement.getString('name');
  }

  Future<bool> removeName() async {
    return _dataManagement.removeData('name');
  }

  Future<bool> doesNameExist() async {
    return _dataManagement.doesDataExist('name');
  }
}
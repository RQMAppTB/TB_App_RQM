import 'DataManagement.dart';

class NameData{
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveName(String name) async {
    return _dataManagement.saveString('name', name);
  }

  static Future<String> getName() async {
    return _dataManagement.getString('name');
  }

  static Future<bool> removeName() async {
    return _dataManagement.removeData('name');
  }

  static Future<bool> doesNameExist() async {
    return _dataManagement.doesDataExist('name');
  }
}
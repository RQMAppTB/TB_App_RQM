import 'DataManagement.dart';

class UuidData{
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveUuid(String uuid) async {
    return _dataManagement.saveString('uuid', uuid);
  }

  static Future<String> getUuid() async {
    return _dataManagement.getString('uuid');
  }

  static Future<bool> removeUuid() async {
    return _dataManagement.removeData('uuid');
  }

  static Future<bool> doesUuidExist() async {
    return _dataManagement.doesDataExist('uuid');
  }
}
import 'DataManagement.dart';

class UuidData{
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveUuid(String uuid) async {
    return _dataManagement.saveString('uuid', uuid);
  }

  Future<String> getUuid() async {
    return _dataManagement.getString('uuid');
  }

  Future<bool> removeUuid() async {
    return _dataManagement.removeData('uuid');
  }

  Future<bool> doesUuidExist() async {
    return _dataManagement.doesDataExist('uuid');
  }
}
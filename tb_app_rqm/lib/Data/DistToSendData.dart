

import 'DataManagement.dart';

class DistToSendData{
  final DataManagement _dataManagement = DataManagement();

  Future<bool> saveDistToSend(int distToSend) async {
    return _dataManagement.saveInt('distToSend', distToSend);
  }

  Future<int?> getDistToSend() async {
    return _dataManagement.getInt('distToSend');
  }

  Future<bool> removeDistToSend() async {
    return _dataManagement.removeData('distToSend');
  }

  Future<bool> doesDistToSendExist() async {
    return _dataManagement.doesDataExist('distToSend');
  }
}
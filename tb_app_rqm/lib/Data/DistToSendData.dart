

import 'DataManagement.dart';

class DistToSendData{
  static final DataManagement _dataManagement = DataManagement();

  static Future<bool> saveDistToSend(int distToSend) async {
    return _dataManagement.saveInt('distToSend', distToSend);
  }

  static Future<int?> getDistToSend() async {
    return _dataManagement.getInt('distToSend');
  }

  static Future<bool> removeDistToSend() async {
    return _dataManagement.removeData('distToSend');
  }

  static Future<bool> doesDistToSendExist() async {
    return _dataManagement.doesDataExist('distToSend');
  }
}
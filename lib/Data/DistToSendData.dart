import 'DataManagement.dart';

/// Class to manage the distance traveled by the user during the measure.
/// This distance is the one sent to the API.
class DistToSendData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the distance [distToSend] to send to the API in the shared preferences.
  static Future<bool> saveDistToSend(int distToSend) async {
    return _dataManagement.saveInt('distToSend', distToSend);
  }

  /// Get the distance to send to the API from the shared preferences.
  static Future<int?> getDistToSend() async {
    return _dataManagement.getInt('distToSend');
  }

  /// Remove the distance to send to the API from the shared preferences.
  static Future<bool> removeDistToSend() async {
    return _dataManagement.removeData('distToSend');
  }

  /// Check if the distance to send to the API exists in the shared preferences.
  static Future<bool> doesDistToSendExist() async {
    return _dataManagement.doesDataExist('distToSend');
  }
}

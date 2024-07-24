import 'DataManagement.dart';

/// Class to manage the time spent on the track.
class TimeData{

  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the time spent on the track [time] in the shared preferences
  static Future<bool> saveTime(int time) async {
    return _dataManagement.saveInt('time', time);
  }

  /// Get the time spent on the track from the shared preferences
  static Future<int?> getTime() async {
    return _dataManagement.getInt('time');
  }

  /// Remove the time spent on the track from the shared preferences
  static Future<bool> removeTime() async {
    return _dataManagement.removeData('time');
  }

  /// Check if the time spent on the track exists in the shared preferences
  Future<bool> doesTimeExist() async {
    return _dataManagement.doesDataExist('time');
  }

}
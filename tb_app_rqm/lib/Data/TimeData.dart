import 'DataManagement.dart';

/// TimeData class
/// This class is used to manage the data about the time spent on the track
/// in the current run.
class TimeData{
  final DataManagement _dataManagement = DataManagement();

  /// Save the time spent on the track
  /// [time] is the time to add to the time spent on the track
  Future<bool> saveTime(int time) async {
    return _dataManagement.saveInt('time', time);
  }

/// Get the time spent on the track
/// Returns the time spent on the track
  Future<int?> getTime() async {
    return _dataManagement.getInt('time');
  }

/// Remove the time spent on the track
/// Returns true if the time spent on the track was successfully removed
  Future<bool> removeTime() async {
    return _dataManagement.removeData('time');
  }

/// Check if the time spent on the track exists
/// Returns true if the time spent on the track exists
  Future<bool> doesTimeExist() async {
    return _dataManagement.doesDataExist('time');
  }

}
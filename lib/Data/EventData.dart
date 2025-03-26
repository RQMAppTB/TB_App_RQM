import 'DataManagement.dart';

/// Class to manage event-related data.
class EventData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save all event details in the shared preferences.
  static Future<bool> saveEvent(Map<String, dynamic> event) async {
    bool idSaved = await _dataManagement.saveInt('event_id', event['id']);
    bool nameSaved =
        await _dataManagement.saveString('event_name', event['name']);
    bool startDateSaved = await _dataManagement.saveString(
        'event_start_date', event['start_date']);
    bool endDateSaved =
        await _dataManagement.saveString('event_end_date', event['end_date']);
    bool metersGoalSaved = await _dataManagement.saveInt(
        'event_meters_goal', event['meters_goal']);
    return idSaved &&
        nameSaved &&
        startDateSaved &&
        endDateSaved &&
        metersGoalSaved;
  }

  /// Get the event ID from the shared preferences.
  static Future<int?> getEventId() async {
    return _dataManagement.getInt('event_id');
  }

  /// Get the event name from the shared preferences.
  static Future<String?> getEventName() async {
    return _dataManagement.getString('event_name');
  }

  /// Get the event start date from the shared preferences.
  static Future<String?> getStartDate() async {
    return _dataManagement.getString('event_start_date');
  }

  /// Get the event end date from the shared preferences.
  static Future<String?> getEndDate() async {
    return _dataManagement.getString('event_end_date');
  }

  /// Get the event meters goal from the shared preferences.
  static Future<int?> getMetersGoal() async {
    return _dataManagement.getInt('event_meters_goal');
  }

  /// Remove all event-related data from the shared preferences.
  static Future<bool> clearEventData() async {
    bool idRemoved = await _dataManagement.removeData('event_id');
    bool nameRemoved = await _dataManagement.removeData('event_name');
    bool startDateRemoved =
        await _dataManagement.removeData('event_start_date');
    bool endDateRemoved = await _dataManagement.removeData('event_end_date');
    bool metersGoalRemoved =
        await _dataManagement.removeData('event_meters_goal');
    return idRemoved &&
        nameRemoved &&
        startDateRemoved &&
        endDateRemoved &&
        metersGoalRemoved;
  }
}

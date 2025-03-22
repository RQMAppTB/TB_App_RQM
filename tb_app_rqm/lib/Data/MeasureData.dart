import 'DataManagement.dart';

/// Class to manage measure-related data.
class MeasureData {
  /// Singleton instance of the DataManagement class.
  static final DataManagement _dataManagement = DataManagement();

  /// Save the measure ID in the shared preferences.
  static Future<bool> saveMeasureId(String measureId) async {
    return _dataManagement.saveString('measure_id', measureId);
  }

  /// Retrieve the measure ID from the shared preferences.
  static Future<String?> getMeasureId() async {
    return _dataManagement.getString('measure_id');
  }

  /// Clear the measure ID from the shared preferences.
  static Future<bool> clearMeasureId() async {
    return _dataManagement.removeData('measure_id');
  }

  /// Check if a measure is ongoing by checking if the measure ID exists and is not empty.
  static Future<bool> isMeasureOngoing() async {
    String? measureId = await getMeasureId();
    return measureId != null && measureId.isNotEmpty; // Ensure measureId is not null or empty
  }
}

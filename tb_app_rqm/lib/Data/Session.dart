import 'package:lrqm/API/MeasureController.dart';
import 'package:lrqm/Data/UuidData.dart';
import 'package:lrqm/Data/DistToSendData.dart';
import 'package:lrqm/Data/TimeData.dart';
import 'package:lrqm/Geolocalisation/Geolocation.dart';

/// Class to manage session-related data.
class Session {
  /// Check if a measure is ongoing by using the MeasureController.
  static Future<bool> isStarted() async {
    return MeasureController.isThereAMeasure();
  }

  /// Start a session by calling MeasureController and saving the UUID.
  static Future<void> startSession(int nbParticipants) async {
    var result = await MeasureController.startMeasure(nbParticipants);
    if (result.hasError) {
      throw Exception(result.error);
    }
  }

  /// Stop a session by calling MeasureController and removing the UUID.
  static Future<void> stopSession() async {
    Geolocation geolocation = Geolocation();
    geolocation.stopListening();
    var result = await MeasureController.stopMeasure();
    if (result.hasError) {
      throw Exception(result.error);
    }
  }

  /// Force stop a session by removing the UUID without calling the API.
  static Future<void> forceStopSession() async {
    await DistToSendData.removeDistToSend();
    await TimeData.removeTime();
    await UuidData.removeUuid();
  }
}

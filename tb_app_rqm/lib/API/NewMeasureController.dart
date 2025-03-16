import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../Utils/Result.dart';
import '../Utils/config.dart';
import '../Data/MeasureData.dart';

class NewMeasureController {
  /// Start a new measure for a user.
  static Future<Result<int>> startMeasure(int userId,
      {int? contributorsNumber}) async {
    if (await MeasureData.isMeasureOngoing()) {
      log("Debug: Measure is already ongoing.");
      throw Exception(
          "Cannot start a new measure while another measure is ongoing.");
    }

    final uri = Uri.https(Config.API_URL, '/measures/start');
    final body = {
      "user_id": userId,
      if (contributorsNumber != null) "contributors_number": contributorsNumber,
    };

    log("Debug: Starting measure with body: $body");

    return http.post(uri,
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"}).then((response) async {
      log("Debug: Received response with status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log("Debug: Response data: $responseData");

        // Use the correct key to retrieve the measure ID
        int? measureId = responseData['id'];
        if (measureId == null) {
          log("Error: id is null in the response.");
          throw Exception("id is null in the response.");
        }

        await MeasureData.saveMeasureId(
            measureId.toString()); // Save the measure ID
        log("Debug: Measure ID saved: $measureId");
        return Result<int>(value: measureId);
      } else {
        log("Error: Failed to start measure with status code: ${response.statusCode}");
        throw Exception('Failed to start measure: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      return Result<int>(error: error.toString());
    });
  }

  /// Edit the meters for a measure.
  static Future<Result<bool>> editMeters(int meters) async {
    if (!await MeasureData.isMeasureOngoing()) {
      log("Debug: No ongoing measure found to edit meters.");
      throw Exception("No ongoing measure found to edit meters.");
    }

    String? measureId = await MeasureData.getMeasureId();
    log("Debug: Retrieved measure ID for editing meters: $measureId");

    final uri = Uri.https(Config.API_URL, '/measures/$measureId');
    final body = {"meters": meters};

    log("Debug: Editing meters for measure $measureId with body: $body");

    return http.put(uri,
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"}).then((response) {
      log("Debug: Received response with status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        log("Debug: Successfully edited meters.");
        return Result<bool>(value: true);
      } else {
        log("Error: Failed to edit meters with status code: ${response.statusCode}");
        throw Exception('Failed to edit meters: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      return Result<bool>(error: error.toString());
    });
  }

  /// Stop a measure.
  static Future<Result<bool>> stopMeasure() async {
    if (!await MeasureData.isMeasureOngoing()) {
      log("Debug: No ongoing measure found to stop.");
      throw Exception("No ongoing measure found to stop.");
    }

    String? measureId = await MeasureData.getMeasureId();
    log("Debug: Retrieved measure ID for stopping: $measureId");

    final uri = Uri.https(Config.API_URL, '/measures/$measureId/stop');

    log("Debug: Stopping measure with ID: $measureId");

    return http.put(uri).then((response) async {
      log("Debug: Received response with status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        await MeasureData.clearMeasureId(); // Clear the measure ID
        log("Debug: Measure ID cleared.");
        return Result<bool>(value: true);
      } else {
        log("Error: Failed to stop measure with status code: ${response.statusCode}");
        throw Exception('Failed to stop measure: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      return Result<bool>(error: error.toString());
    });
  }
}

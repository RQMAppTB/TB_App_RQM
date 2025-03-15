import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../Utils/Result.dart';
import '../Utils/config.dart';

class NewMeasureController {
  /// Start a new measure for a user.
  static Future<Result<bool>> startMeasure(int userId, {int? contributorsNumber}) async {
    final uri = Uri.https(Config.API_URL, '/measures/start');
    final body = {
      "user_id": userId,
      "contributors_number": contributorsNumber,
    };

    log("Starting measure: $body");

    return http.post(uri, body: jsonEncode(body), headers: {"Content-Type": "application/json"}).then((response) {
      if (response.statusCode == 200) {
        return Result<bool>(value: true);
      } else {
        throw Exception('Failed to start measure: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      return Result<bool>(error: error.toString());
    });
  }

  /// Edit the meters for a measure.
  static Future<Result<bool>> editMeters(int measureId, int meters) async {
    final uri = Uri.https(Config.API_URL, '/measures/$measureId');
    final body = {"meters": meters};

    log("Editing meters for measure $measureId: $body");

    return http.put(uri, body: jsonEncode(body), headers: {"Content-Type": "application/json"}).then((response) {
      if (response.statusCode == 200) {
        return Result<bool>(value: true);
      } else {
        throw Exception('Failed to edit meters: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      return Result<bool>(error: error.toString());
    });
  }

  /// Stop a measure.
  static Future<Result<bool>> stopMeasure(int measureId) async {
    final uri = Uri.https(Config.API_URL, '/measures/$measureId/stop');

    log("Stopping measure $measureId");

    return http.put(uri).then((response) {
      if (response.statusCode == 200) {
        return Result<bool>(value: true);
      } else {
        throw Exception('Failed to stop measure: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error");
      return Result<bool>(error: error.toString());
    });
  }
}

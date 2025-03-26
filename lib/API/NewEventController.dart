import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../Utils/Result.dart';
import '../Utils/config.dart';

class NewEventController {
  /// Create a new event with the provided details.
  static Future<Result<bool>> createEvent(String name, String startDate, String endDate, int metersGoal) async {
    final uri = Uri.https(Config.API_URL, '/events');
    final body = {
      "name": name,
      "start_date": startDate,
      "end_date": endDate,
      "meters_goal": metersGoal,
    };

    log("Request: POST $uri\nBody: ${jsonEncode(body)}");

    return http.post(uri, body: jsonEncode(body), headers: {"Content-Type": "application/json"}).then((response) {
      log("Response: ${response.statusCode}\nBody: ${response.body}");
      if (response.statusCode == 200) {
        return Result<bool>(value: true);
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error\nStackTrace: $stackTrace");
      return Result<bool>(error: error.toString());
    });
  }

  /// Retrieve all events.
  static Future<Result<List<dynamic>>> getAllEvents() async {
    final uri = Uri.https(Config.API_URL, '/events');

    log("Request: GET $uri");

    return http.get(uri).then((response) {
      log("Response: ${response.statusCode}\nBody: ${response.body}");
      if (response.statusCode == 200) {
        return Result<List<dynamic>>(value: jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch events: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error\nStackTrace: $stackTrace");
      return Result<List<dynamic>>(error: error.toString());
    });
  }

  /// Retrieve an event by ID.
  static Future<Result<Map<String, dynamic>>> getEventById(int eventId) async {
    final uri = Uri.https(Config.API_URL, '/events/$eventId');

    log("Request: GET $uri");

    return http.get(uri).then((response) {
      log("Response: ${response.statusCode}\nBody: ${response.body}");
      if (response.statusCode == 200) {
        return Result<Map<String, dynamic>>(value: jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch event: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error\nStackTrace: $stackTrace");
      return Result<Map<String, dynamic>>(error: error.toString());
    });
  }

  /// Get the number of active users for an event.
  static Future<Result<int>> getActiveUsers(int eventId) async {
    final uri = Uri.https(Config.API_URL, '/events/$eventId/active_users');

    log("Request: GET $uri");

    return http.get(uri).then((response) {
      log("Response: ${response.statusCode}\nBody: ${response.body}");
      if (response.statusCode == 200) {
        return Result<int>(value: jsonDecode(response.body)['active_users_number']);
      } else {
        throw Exception('Failed to fetch active users: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error\nStackTrace: $stackTrace");
      return Result<int>(error: error.toString());
    });
  }

  /// Get the total meters for an event.
  static Future<Result<int>> getTotalMeters(int eventId) async {
    final uri = Uri.https(Config.API_URL, '/events/$eventId/meters');

    log("Request: GET $uri");

    return http.get(uri).then((response) {
      log("Response: ${response.statusCode}\nBody: ${response.body}");
      if (response.statusCode == 200) {
        return Result<int>(value: jsonDecode(response.body)['total_meters']);
      } else {
        throw Exception('Failed to fetch total meters: ${response.statusCode}');
      }
    }).onError((error, stackTrace) {
      log("Error: $error\nStackTrace: $stackTrace");
      return Result<int>(error: error.toString());
    });
  }
}

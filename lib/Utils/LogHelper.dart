import 'dart:async';

class LogHelper {
  static final StreamController<String> _logStreamController =
      StreamController<String>.broadcast();

  static Stream<String> get logStream => _logStreamController.stream;

  static void writeLog(String msg) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp: $msg';
    _logStreamController.add(logEntry); // Add log to the stream
  }

  static void dispose() {
    _logStreamController.close(); // Close the stream when no longer needed
  }
}

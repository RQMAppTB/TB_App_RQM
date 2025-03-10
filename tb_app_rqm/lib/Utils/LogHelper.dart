import 'dart:io';
import 'dart:developer';
import 'package:path_provider/path_provider.dart';

class LogHelper {
  static Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/logs.txt');
  }

  static Future<void> writeLog(String msg) async {
    final file = await _getLogFile();
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp: $msg';
    
    log(logEntry);
    
    // Write the log to the file
    await file.writeAsString('$logEntry\n', mode: FileMode.append);
  }

  static Future<String> readLogs() async {
    try {
      final file = await _getLogFile();
      return await file.readAsString();
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }
}

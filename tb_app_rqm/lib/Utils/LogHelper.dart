import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class LogHelper {
  static Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/logs.txt');
  }

  static Future<void> writeLog(String msg) async {
    final file = await _getLogFile();
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '$timestamp,$msg';
    
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

  static Future<File> getLogFile() async {
    return await _getLogFile();
  }

  static Future<File> moveLogFileToDownloads() async {
    final logFile = await _getLogFile();
    final downloadsDirectory = await getExternalStorageDirectory();
    final newFilePath = '${downloadsDirectory!.path}/logs.txt';
    final newFile = await logFile.copy(newFilePath);
    return newFile;
  }

  static Future<void> shareLogFile() async {
    final logFile = await _getLogFile();
    await Share.shareFiles([logFile.path], text: 'Here are the logs.');
  }
}

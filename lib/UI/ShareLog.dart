import 'package:flutter/material.dart';
import 'package:lrqm/Utils/LogHelper.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await LogHelper.moveLogFileToDownloads();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Log file moved to Downloads')),
                );
              },
              child: Text('Move Log File to Downloads'),
            ),
            ElevatedButton(
              onPressed: () async {
                await LogHelper.shareLogFile();
              },
              child: Text('Share Log File via Email'),
            ),
          ],
        ),
      ),
    );
  }
}

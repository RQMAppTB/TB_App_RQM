import 'package:flutter/material.dart';
import '../../Utils/LogHelper.dart';

class ShareLog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<String>(
          stream: LogHelper.logStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: Text('No logs yet.'));
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  snapshot.data!,
                  style: TextStyle(fontSize: 14, fontFamily: 'monospace'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

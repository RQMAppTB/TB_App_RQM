import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

class WorkingScreen extends StatefulWidget{
  const WorkingScreen({super.key});

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

class _WorkingScreenState extends State<WorkingScreen>{
  // Create a stream
  StreamController<int> _streamController = StreamController<int>();
  //var status = await Permission.location.status;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    log("Dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async{
        log("Trying to pop");
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Measuring'),
        ),
        body: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(image: AssetImage('assets/LogoText.png')),
              const Padding(padding: EdgeInsets.all(10)),

            ],
          ),
        ),
      ),
    );
  }
}
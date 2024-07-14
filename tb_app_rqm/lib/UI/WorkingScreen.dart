import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tb_app_rqm/API/MeasureController.dart';
import 'package:tb_app_rqm/UI/InfoScreen.dart';

import '../Geolocalisation/Geolocation.dart';

class WorkingScreen extends StatefulWidget{
  const WorkingScreen({super.key});

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

class _WorkingScreenState extends State<WorkingScreen>{
  // Create a stream
  Geolocation _geolocation = Geolocation();
  StreamController<int> _streamController = StreamController<int>();
  int _value = 0;
  //var status = await Permission.location.status;

  @override
  void initState() {
    super.initState();
    _streamController.stream.listen((event) {
      log("Stream event: $event");
      setState(() {
        _value = event;
      });
    });

    _geolocation.startListening(_streamController.sink);

  }

  @override
  void dispose() {
    log("Dispose");
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: Text('Voulez-vous arrêter la session?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _geolocation.stopListening();
                MeasureController.stopMeasure();
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const InfoScreen()), (route) => false);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              },
            ),
          ],
        );
      },
    );
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
          centerTitle: true,
          title: const Text('Un mêtre de plus ça compte'),
        ),
        body: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      const Spacer(),
                      const Expanded(
                        flex: 2,
                        child: Image(image: AssetImage('assets/pictures/LogoText.png')),
                      ),
                      Expanded(
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              'Vous avez parcouru $_value mètres cette session'

                            ),
                            const Text('Courage, vous êtes bien parti!'),
                          ],

                        )
                      )
                      //const Image(image: AssetImage('assets/pictures/LogoText.png')),
                      /*const Padding(padding: EdgeInsets.all(10)),
                      Text('Vous avez parcouru $_value mètres cette session'),
                      const Text('Courage, vous êtes bien parti!'),*/
                    ]
                  ),
                ),
              ),

              //Create a clickable expanded
              Expanded(
                flex: 1,
                child:SizedBox(
                  width: double.infinity,
                  child:ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () async {
                      log("Result: starting?");
                      _showMyDialog();
                      //await _geolocation.startListening(_streamController.sink);
                    },
                    child: const Text('Stop'),
                  ),
                ),



                /*Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child:
                      ),
                    )
                  ],

                ),*/
              ),

            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lrqm/API/MeasureController.dart';
import 'package:lrqm/UI/InfoScreen.dart';
import 'package:lrqm/Utils/config.dart';

import '../Geolocalisation/Geolocation.dart';

/// Class to display the working screen.
/// This screen displays the distance traveled by the user.
/// The user can stop the measure by clicking on the stop button
/// and is redirected to the information screen.
class WorkingScreen extends StatefulWidget {
  const WorkingScreen({super.key});

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

/// State of the WorkingScreen class.
class _WorkingScreenState extends State<WorkingScreen> {
  /// Instance of the Geolocation class
  Geolocation _geolocation = Geolocation();

  /// Value of the distance traveled by the user
  int _value = 0;

  @override
  void initState() {
    super.initState();
    // Start listening to the distance stream
    _geolocation.stream.listen((event) {
      log("Stream event: $event");
      if (event == -1) {
        log("Stream event: $event");
        _geolocation.stopListening();
        MeasureController.stopMeasure();
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => const InfoScreen()), (route) => false);
      } else {
        setState(() {
          _value = event;
        });
      }
    });
    _geolocation.startListening();
  }

  @override
  void dispose() {
    super.dispose();
    log("Dispose");
    _geolocation.stopListening();
  }

  /// Function to show a dialog to confirm the end of the measure.
  /// The user is redirected to the information screen if he confirms.
  /// The measure the measure is only stopped if the user confirms.
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fin de la session'),
          content: const SingleChildScrollView(
            child: Text('Voulez-vous vraiment vous arrêter?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Oui'),
              onPressed: () {
                _geolocation.stopListening();
                MeasureController.stopMeasure();
                Navigator.pushAndRemoveUntil(
                    context, MaterialPageRoute(builder: (context) => const InfoScreen()), (route) => false);
              },
            ),
            TextButton(
              child: const Text('Non'),
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
      onPopInvoked: (bool didPop) async {
        log("Trying to pop");
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(Config.COLOR_APP_BAR),
          centerTitle: true,
          title: const Text(style: TextStyle(color: Color(Config.COLOR_TITRE)), 'Même un mètre de plus, ça compte'),
        ),
        body: Center(
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 9,
                child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
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
                            Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        'Vous avez parcouru'),
                                    Text(
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                        ' $_value mètres '),
                                  ],
                                )),
                            const Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                        'Courage, vous êtes bien parti!'),
                                  ],
                                ))
                          ],
                        ))
                  ]),
                ),
              ),

              //Create a clickable expanded
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(Config.COLOR_BUTTON),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () async {
                      log("Result: starting?");
                      _showMyDialog();
                    },
                    child: const Text('Stop'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

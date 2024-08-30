import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tb_app_rqm/API/DistanceController.dart';

import '../API/LoginController.dart';
import '../API/MeasureController.dart';
import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Data/DossardData.dart';
import '../Data/NameData.dart';
import '../Geolocalisation/Geolocation.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'ConfigScreen.dart';
import 'LoginScreen.dart';

/// Class to display the information screen.
/// This screen displays the remaining time before the end of the event,
/// the total distance traveled by all participants,
/// the distance traveled by the current participant,
/// the dossard number and the name of the user.
class InfoScreen extends StatefulWidget{
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

/// State of the InfoScreen class.
class _InfoScreenState extends State<InfoScreen>{

  /// Timer to update the remaining time every second
  Timer? _timer;
  /// Start time of the event
  DateTime start = DateTime.parse(Config.START_TIME);
  /// End time of the event
  DateTime end = DateTime.parse(Config.END_TIME);
  /// Remaining time before the end of the event
  String _remainingTime = "";
  /// Total distance traveled by all participants
  int? _distanceTotale;
  /// Distance traveled by the current participant
  int? _distancePerso;
  /// Dossard number of the user
  String _dossard = "";
  /// Name of the user
  String _name = "";
  /// Boolean to check if the start button is enabled
  bool _enabledStart = true;

  /// Function to show a snackbar with the message [value]
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }

  /// Function to update the remaining time every second
  void countDown() {
    DateTime now = DateTime.now();
    Duration remaining = end.difference(now);
    if(remaining.isNegative){
      _timer?.cancel();
      setState(() {
        _enabledStart = false;
        _remainingTime = "L'évènement est terminé !";
      });
      return;
    }else if(now.isBefore(start)){
      setState(() {
        _enabledStart = false;
        _remainingTime = "L'évènement n'a pas encore commencé !";
      });
      return;
    }

    setState(() {
      _remainingTime = '${remaining.inHours}:${(remaining.inMinutes)%60}:${(remaining.inSeconds)%60}';
    });
  }

  /// Function to get the value from the API [fetchVal]
  /// and if it fails, get the value from the shared preferences [getVal]
  /// Returns the value
  /// If the value is not found, returns -1
  Future<int> _getValue(Future<Result<int>> Function() fetchVal, Future<int?> Function() getVal) {
    return fetchVal()
        .then((value) {
          if(value.hasError){
            throw Exception("Could not fetch value because : ${value.error}");
          }else{
            log("Value: ${value.value}");
            return value.value!;
          }
        })
        .onError((error, stackTrace) {
          log('Error here: $error');
          return getVal()
              .then((value){
                if(value == null){
                  log("No value");
                  return -1;
                }else{
                  return value;
                }
              });
        });
  }

  @override
  void initState() {
    super.initState();

    // Check if the event has started or ended
    if(DateTime.now().isAfter(end) || DateTime.now().isBefore(start)){
      _enabledStart = false;
      _remainingTime = "L'évènement ${DateTime.now().isAfter(end) ? "est terminé" : "n'a pas encore commencé"} !";
    }else{
      Geolocation.handlePermission()
          .then((value) {
        if(!value){
          log('Location permission not granted');
          exit(0);
        }else{
          log('Location permission granted');
        }
      }).onError((error, stackTrace) {
        log('Error: $error');
        exit(0);
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => countDown());
    }

    // Get the total distance
    _getValue(DistanceController.getTotalDistance, DistTotaleData.getDistTotale)
        .then((value) => setState(() {
          _distanceTotale = value;
        }));

    // Get the personal distance
    _getValue(DistanceController.getPersonalDistance, DistPersoData.getDistPerso)
        .then((value) => setState(() {
      _distancePerso = value;
    }));

    // Get the dossard number
    DossardData.getDossard().then((value) => setState(() {
      setState(() {
        _dossard = value.toString().padLeft(4, '0');
      });
    }));

    // Get the name of the user
    NameData.getName().then((value) => setState(() {
      setState(() {
        _name = value;
      });
    }));
  }

  @override
  void dispose() {
    log("Dispose");
    _timer?.cancel();
    super.dispose();
  }

  /// Function to go to the configuration screen
  Future<void> _startMeasure() async{
    log("Start measure");
    setState(() {
      _enabledStart = false;
    });
    bool canStartNewMeasure = true;
    if(await MeasureController.isThereAMeasure()){
      Result result = await MeasureController.stopMeasure();
      canStartNewMeasure = !result.hasError;
    }

    log("Can start new measure: $canStartNewMeasure");

    if(await Geolocation.handlePermission()){
      log("1");
      if(await Geolocation().isInZone()){
        log("2");
        if(canStartNewMeasure) {
          log("3");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ConfigScreen()),
          );
        }
      }else{
        showInSnackBar("Vous n'êtes pas dans la zone");
        log("You are not in the zone");
      }
    }else{
      showInSnackBar("Vous n'avez pas autorisé la localisation");
      log("You did not allow location");
    }

    log("4");
    setState(() {
      _enabledStart = true;
    });

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
          backgroundColor: const Color(Config.COLOR_APP_BAR),
          centerTitle: true,
          title: const Text(
              style: TextStyle(color: Color(Config.COLOR_TITRE)),
              'Info'
          ),
          actions: [
            // Logout button
            IconButton(
              icon: const Icon(
                  color: Color(Config.COLOR_TITRE),
                  Icons.logout
              ),
              onPressed: () {
                LoginController.logout().then((result){
                  if(result.hasError){
                    showInSnackBar("Please try again later");
                  }else{
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  }
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 9,
                  child: Center(
                      child: Column(
                        children: <Widget>[
                          const Expanded(
                            flex: 2,
                            child: Image(image: AssetImage('assets/pictures/LogoText.png')),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Bonjour N°$_dossard : $_name'),
                                Text('Vous avez parcouru ${_distancePerso ?? 0} mètres'),
                              ]
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text('Temps restant'),
                                    Text(_remainingTime),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Text('Distance totale'),
                                    Text('${_distanceTotale ?? 0}'),
                                  ],
                                )
                              ],
                            )
                          ),
                        ]
                      )
                  )
              ),

              Expanded(
                flex: 1,
                child:SizedBox(
                  width: double.infinity,
                  // Start button
                  child:ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(Config.COLOR_BUTTON),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () async{
                      _enabledStart ? await _startMeasure() : null;
                    },
                    child: const Text('Start'),
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
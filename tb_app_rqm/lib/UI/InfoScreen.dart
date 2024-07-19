import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tb_app_rqm/API/EventController.dart';

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

class InfoScreen extends StatefulWidget{
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen>{

  // ----------------- Variables -----------------
  Timer? _timer;
  DateTime start = DateTime.parse(Config.START_TIME);
  DateTime end = DateTime.parse(Config.END_TIME);
  String _remainingTime = "";
  int? _distanceTotale;
  int? _distancePerso;
  String _dossard = "";
  String _name = "";
  bool _enabledStart = true;


  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }

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
    }

    setState(() {
      _remainingTime = '${remaining.inHours}:${(remaining.inMinutes)%60}:${(remaining.inSeconds)%60}';
    });
  }

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


    _getValue(EventController.getTotalDistance, DistTotaleData.getDistTotale)
        .then((value) => setState(() {
          _distanceTotale = value;
        }));

    _getValue(EventController.getPersonalDistance, DistPersoData.getDistPerso)
        .then((value) => setState(() {
      _distancePerso = value;
    }));

    DossardData.getDossard().then((value) => setState(() {
      setState(() {
        _dossard = value.toString().padLeft(4, '0');
      });
    }));
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
      if(await Geolocation().isInZone()){
        if(canStartNewMeasure) {
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

    setState(() {
      _enabledStart = true;
    });

  }


  int _test = -1;

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
            IconButton(
              icon: const Icon(Icons.logout),
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
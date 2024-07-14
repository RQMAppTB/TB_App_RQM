import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
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
  //final String _end = ;
  DateTime end = DateTime.parse(Config.END_TIME);
  String _remainingTime = "";
  int? _distanceTotale;
  int? _distancePerso;
  String _dossard = "";
  String _name = "";
  //LoginApi _loginApi = LoginApi();
  DossardData _dossardData = DossardData();
  NameData _nameData = NameData();
  //DistTotaleData _distTotaleData = DistTotaleData();
  //DistPersoData _distPersoData = DistPersoData();

  // API controllers
  //MeasureController _measureController = MeasureController();


  // Create a stream


  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text(value)
    ));
  }

  void countDown() {
    DateTime now = DateTime.now();
    Duration remaining = end.difference(now);

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
          log('Error: $error');
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
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => countDown());

    _getValue(EventController.getTotalDistance, DistTotaleData.getDistTotale)
        .then((value) => setState(() {
          _distanceTotale = value;
        }));

    _getValue(EventController.getPersonalDistance, DistPersoData.getDistPerso)
        .then((value) => setState(() {
      _distancePerso = value;
    }));
    /*
    EventController.getTotalDistance()
        .then((value) {
          if(value.hasError){
            throw Exception("Could not retrieve total distance : ${value.error}");
          }else{
            setState(() {
              _distanceTotale = value.value;
            });
          }
        })
        .onError((error, stackTrace) {
          log('Error: $error');
          DistTotaleData.getDistTotale()
              .then((value){
                if(value == null){
                  log("No total distance saved");
                  setState(() {
                    _distanceTotale = -1;
                  });
                }else{
                  setState(() {
                    _distanceTotale = value;
                  });
                }
              });
        });*/

/*
    EventController.getPersonalDistance()
        .then((value) {
          if(value.hasError){
            throw Exception("Could not retrieve personal distance : ${value.error}");
          }else{
            setState(() {
              _distancePerso = value.value;
            });
          }
        })
        .onError((error, stackTrace) {
          log('Error: $error');
          DistPersoData.getDistPerso()
              .then((value){
                if(value == null){
                  log("No personal distance saved");
                  setState(() {
                    _distancePerso = -1;
                  });
                }else{
                  setState(() {
                    _distancePerso = value;
                  });
                }
              });
        });*/

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async{
        log("Trying to pop");
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Info'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                LoginController.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('La Roue Qui Marche'),
              const Padding(padding: EdgeInsets.all(10)),
              const Text('Temps restant'),
              Text(_remainingTime),
              const Text('Distance totale'),
              Text('${_distanceTotale ?? 0}'),
              const Padding(padding: EdgeInsets.all(10)),
              Text('$_dossard $_name'),
              Text('Vous avez parcouru ${_distancePerso ?? 0} mètres'),
              ElevatedButton(
                onPressed: () async{
                  bool canStartNewMeasure = true;
                  if(await MeasureController.isThereAMeasure()){
                    Result result = await MeasureController.stopMeasure();
                    canStartNewMeasure = !result.hasError;
                  }

                  log("Can start new measure: $canStartNewMeasure");

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
                },
                child: const Text('Start'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
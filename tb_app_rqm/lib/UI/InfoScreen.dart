import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Data/DossardData.dart';
import '../Data/NameData.dart';
import '../Utils/config.dart';
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
  int _distanceTotale = 0;
  int _distancePerso = 0;
  //LoginApi _loginApi = LoginApi();
  DossardData _dossardData = DossardData();
  NameData _nameData = NameData();
  DistTotaleData _distTotaleData = DistTotaleData();
  DistPersoData _distPersoData = DistPersoData();

  // API controllers
  //MeasureController _measureController = MeasureController();


  // Create a stream


  void countDown() {
    DateTime now = DateTime.now();
    Duration remaining = end.difference(now);

    setState(() {
      _remainingTime = '${remaining.inHours}:${(remaining.inMinutes)%60}:${(remaining.inSeconds)%60}';
    });
  }

  @override
  void initState() {
    super.initState();
    //compute((_){_timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => countDown());}, 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => countDown());
    _distTotaleData.getDistTotale().then((value) => setState(() {
      setState(() {
        _distanceTotale = value ?? 0;
      });
    }));
    _distPersoData.getDistPerso().then((value) => setState(() {
      setState(() {
        _distancePerso = value ?? 0;
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
              Text('$_distanceTotale'),
              const Text('Distance personnelle'),
              Text('$_distancePerso'),
              ElevatedButton(
                onPressed: () async{
                  /*bool canStartNewMeasure = true;
                  if(await MeasureController.isThereAMeasure()){
                    Result result = await MeasureController.stopMeasure();
                    canStartNewMeasure = !result.hasError;
                  }

                  if(await Geolocation.isLocationInZone()){
                    if(canStartNewMeasure) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ConfigScreen()),
                      );
                    }
                  }else{

                  }*/
                },
                child: const Text('Start mesure'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
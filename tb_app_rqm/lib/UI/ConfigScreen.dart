import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tb_app_rqm/API/MeasureController.dart';

import '../Data/NbPersonData.dart';
import '../Utils/config.dart';
import 'WorkingScreen.dart';
class ConfigScreen extends StatefulWidget{
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen>{

  int _nbParticipants = 1;
  NbPersonData _nbPersonData = NbPersonData();

  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    autoStart: true,
  );


  Barcode? _barcode;

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted && barcodes.barcodes.isNotEmpty && barcodes.barcodes.first.displayValue == Config.QR_CODE_S_VALUE) {

      controller.stop();
      _showMyDialog();
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vous êtes $_nbParticipants participants'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Êtes-vous sûr de vouloir commencer la mesure ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Oui'),
              onPressed: () {
                NbPersonData.saveNbPerson(_nbParticipants);
                MeasureController.startMeasure(_nbParticipants)
                    .then((result) {
                      log("Result: $result");
                      if(result.error != null){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Vous ne pouvez pas commencer de mesure maintenant, réessayez plus tard"),
                          ),
                        );
                        log("Error: ${result.error}");
                        return;
                      }
                      controller.dispose();
                      Navigator.pushAndRemoveUntil(
                        context, MaterialPageRoute(builder: (context) => const WorkingScreen()), (route) => false);
                    })
                    .onError((error, stackTrace) {
                      log("Error: $error");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error while starting the measure'),
                        ),
                      );
                    });
              },
            ),
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                controller.start();
              },
            ),
          ],
        );
      },
    );
  }

  /// Function to add a participant
  /// This function increments the number of participants
  /// by one as long as the number of participants is less than 4
  void addParticipant(){
    if(_nbParticipants < 4){
      setState(() {
        _nbParticipants++;
      });
    }
  }

  /// Function to remove a participant
  /// This function decrements the number of participants
  /// by one as long as the number of participants is greater than 1
  void removeParticipant(){
    if(_nbParticipants > 1){
      setState(() {
        _nbParticipants--;
      });
    }
  }

  @override
  void dispose(){
    super.dispose();
    log("Dispose");
    controller.dispose();
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) async{
        log("Trying to pop");
        controller.dispose();
      },
      child: Scaffold(
        appBar: AppBar(
            iconTheme: const IconThemeData(
                color: Color(Config.COLOR_TITRE)
            ),
            backgroundColor: const Color(Config.COLOR_APP_BAR),
            centerTitle: true,
            title: const Text(
                style: TextStyle(color: Color(Config.COLOR_TITRE)),
                'Config'
            )
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: MobileScanner(
                  onDetect: _handleBarcode,
                  controller: controller,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.all(10.0)),
                        const Text('Combien de personnes participent ?'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            IconButton(
                              onPressed: removeParticipant,
                              icon: const Icon(Icons.remove),
                            ),
                            Text('$_nbParticipants'),
                            IconButton(
                              onPressed: addParticipant,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ]
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}
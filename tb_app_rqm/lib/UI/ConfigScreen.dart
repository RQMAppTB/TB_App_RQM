import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lrqm/API/MeasureController.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../Data/NbPersonData.dart';
import '../Utils/config.dart';
import 'WorkingScreen.dart';

/// Class to display the configuration screen.
/// This screen allows the user to configure the number of participants
/// and start the measure by scanning a QR code.
class ConfigScreen extends StatefulWidget {
  final int nbParticipants;

  const ConfigScreen({super.key, required this.nbParticipants});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

/// State of the ConfigScreen class.
class _ConfigScreenState extends State<ConfigScreen> {
  /// Instance of the MobileScannerController class
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    autoStart: true,
  );

  /// Function to handle the barcode detection
  /// This function stops the scanner when the QR code is detected
  /// and shows a dialog to confirm the start of the measure.
  /// [barcodes] : List of detected barcodes
  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted && barcodes.barcodes.isNotEmpty && barcodes.barcodes.first.displayValue == Config.QR_CODE_S_VALUE) {
      controller.stop();
      _showMyDialog();
    }
  }

  /// This function shows a dialog to confirm the start of the measure
  /// and starts the measure if the user confirms.
  /// The number of participants is saved in the shared preferences.
  /// The user is redirected to the WorkingScreen if the measure starts successfully.
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vous êtes ${widget.nbParticipants} participants'),
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
                NbPersonData.saveNbPerson(widget.nbParticipants);
                MeasureController.startMeasure(widget.nbParticipants).then((result) {
                  log("Result: $result");
                  if (result.error != null) {
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
                }).onError((error, stackTrace) {
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

  @override
  void dispose() {
    super.dispose();
    log("Dispose");
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvoked: (bool didPop) async {
          log("Trying to pop");
          controller.dispose();
        },
        child: Scaffold(
          appBar: AppBar(
              iconTheme: const IconThemeData(color: Color(Config.COLOR_TITRE)),
              backgroundColor: const Color(Config.COLOR_APP_BAR),
              centerTitle: true,
              title: GestureDetector(
                onDoubleTap: () {
                  _handleBarcode(const BarcodeCapture(barcodes: [Barcode(displayValue: Config.QR_CODE_S_VALUE)]));
                },
                child: const Text(
                  'Config',
                  style: TextStyle(color: Color(Config.COLOR_TITRE)),
                ),
              )),
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
              ],
            ),
          ),
        ));
  }
}

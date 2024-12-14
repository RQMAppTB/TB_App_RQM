import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../Utils/config.dart';
import 'LoadingScreen.dart';
import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import 'WorkingScreen.dart';
import 'package:lrqm/Data/Session.dart';
import 'package:lrqm/Data/NbPersonData.dart';

/// Class to display the setup scan screen.
/// This screen allows the user to configure the number of participants
/// and start the measure by scanning a QR code.
class SetupScanScreen extends StatefulWidget {
  final int nbParticipants;

  const SetupScanScreen({super.key, required this.nbParticipants});

  @override
  State<SetupScanScreen> createState() => _SetupScanScreenState();
}

/// State of the SetupScanScreen class.
class _SetupScanScreenState extends State<SetupScanScreen> {
  /// Instance of the MobileScannerController class
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    autoStart: true,
  );

  bool _isLoading = false; // Add _isLoading property
  bool _isCameraOpen = false; // Add _isCameraOpen property

  void _navigateToLoadingScreen() {
    controller.stop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoadingScreen(
          text: "À vos marques, prêts, partez !",
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () async {
      await NbPersonData.saveNbPerson(widget.nbParticipants); // Save the number of participants
      await Session.startSession(widget.nbParticipants);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WorkingScreen()),
        (route) => false,
      );
    });
  }

  /// Function to handle the barcode detection
  /// This function stops the scanner when the QR code is detected
  /// and shows a dialog to confirm the start of the measure.
  /// [barcodes] : List of detected barcodes
  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted && barcodes.barcodes.isNotEmpty && barcodes.barcodes.first.displayValue == Config.QR_CODE_S_VALUE) {
      _navigateToLoadingScreen();
    }
  }

  void _launchCamera() async {
    try {
      setState(() {
        _isCameraOpen = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ouverture de la caméra')),
      );
    }
  }

  void _quitCamera() {
    setState(() {
      _isCameraOpen = false;
    });
    controller.stop();
  }

  void _startSessionDirectly() {
    setState(() {
      _isLoading = true;
    });
    _navigateToLoadingScreen();
  }

  @override
  void dispose() {
    super.dispose();
    log("Dispose");
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            // Make the full page scrollable
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 90),
                  Center(
                    child: GestureDetector(
                      onDoubleTap: _startSessionDirectly,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: const Image(image: AssetImage('assets/pictures/DrawScan-removebg.png')),
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InfoCard(
                      title: "Le petit oiseau va sortir !",
                      data: "Prend en photo le QR code pour démarrer ta session",
                      actionItems: [],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 100), // Add more margin at the bottom to allow more scrolling
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft, // Fix the back button at the top
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 10), // Add padding
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(Config.COLOR_APP_BAR), size: 32),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          if (!_isCameraOpen)
            Align(
              alignment: Alignment.bottomCenter, // Fix the "Ouvrir la caméra" button at the bottom
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0), // Add padding
                child: ActionButton(
                  icon: Icons.camera_alt,
                  text: "Ouvrir la caméra",
                  onPressed: _launchCamera,
                ),
              ),
            ),
          if (_isCameraOpen)
            Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _handleBarcode,
                ),
                Positioned(
                  top: 40,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: _quitCamera,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

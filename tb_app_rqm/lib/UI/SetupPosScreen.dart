import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import 'Components/TextModal.dart';

import '../Utils/config.dart';

import 'LoadingScreen.dart';
import 'SetupTeamScreen.dart';

import '../Geolocalisation/Geolocation.dart';
import '../API/NewMeasureController.dart';
import '../Data/MeasureData.dart';

class SetupPosScreen extends StatefulWidget {
  const SetupPosScreen({super.key});

  @override
  _SetupPosScreenState createState() => _SetupPosScreenState();
}

class _SetupPosScreenState extends State<SetupPosScreen> {
  Position? _currentPosition;
  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      var status = await Permission.location.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        showTextModal(
          context,
          "Accès à la localisation refusé",
          "On dirait que l'accès à la localisation est bloqué. Va dans les paramètres de ton téléphone et autorise l'application à utiliser la localisation. Appuie sur OK pour être redirigé.",
          showConfirmButton: true,
          onConfirm: () async {
            await openAppSettings(); // Open app settings for the user to allow permissions
          },
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      showTextModal(
        context,
        "Erreur d'accès à la localisation",
        "Une erreur inattendue s'est produite. Vérifie les paramètres de ton téléphone pour autoriser l'application à utiliser la localisation. Appuie sur OK pour réessayer.",
        showConfirmButton: true,
        onConfirm: _getCurrentLocation, // Retry getting the location
      );
    }
  }

  void _openInGoogleMaps() async {
    const url =
        'geo:${Config.LAT1},${Config.LON1}?q=${Config.LAT1},${Config.LON1}';
    await launch(url);
  }

  void _copyCoordinates() {
    const coordinates = '${Config.LAT1}, ${Config.LON1}';
    Clipboard.setData(const ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Les coordonnées ont été copiées dans le presse-papiers.')),
    );
  }

  void _showMapModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              1, // Increase height to take more space
          margin: const EdgeInsets.symmetric(
              vertical: 20.0, horizontal: 20.0), // Add margin left and right
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), // Add rounded borders
            boxShadow: const [
              // Add box shadow
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 5.0,
                offset: Offset(0, 5),
              ),
            ],
            color: Colors.white, // Set the color of the container to white
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(30.0), // Clip the map to rounded borders
            child: Stack(
              children: [
                FlutterMap(
                  mapController: MapController(),
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: LatLngBounds(
                        const LatLng(Config.LAT1, Config.LON1),
                        LatLng(_currentPosition?.latitude ?? Config.LAT1,
                            _currentPosition?.longitude ?? Config.LON1),
                      ),
                      padding: const EdgeInsets.all(
                          50.0), // Increase padding to zoom out more
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        const Marker(
                          point: LatLng(
                              Config.LAT1, Config.LON1), // Updated coordinates
                          child: Icon(Icons.place,
                              color: Color(Config.COLOR_BUTTON),
                              size: 48), // Increase icon size
                        ),
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(_currentPosition!.latitude,
                                _currentPosition!.longitude),
                            child: const Icon(Icons.my_location,
                                color: Color(Config.COLOR_APP_BAR),
                                size: 48), // Increase icon size
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.black, size: 32),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToSetupTeamScreen() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    bool canStartNewMeasure = true;
    if (await MeasureData.isMeasureOngoing()) {
      String? measureId = await MeasureData.getMeasureId();
      log("Ongoing measure ID: $measureId");
      final stopResult = await NewMeasureController.stopMeasure();
      canStartNewMeasure = !stopResult.hasError;
      if (stopResult.hasError) {
        showInSnackBar("Failed to stop ongoing measure: ${stopResult.error}");
        log("Failed to stop measure: ${stopResult.error}");
      }
    }

    log("Can start new measure: $canStartNewMeasure");

    if (await Geolocation.handlePermission()) {
      log("1");
      if (await Geolocation().isInZone()) {
        log("2");
        if (canStartNewMeasure) {
          log("3");
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const SetupTeamScreen()), // Navigate to the next screen
          );
        }
      } else {
        final distance = await Geolocation().distanceToZone();
        final distanceText = distance > 0
            ? "Tu es actuellement à ${distance.toStringAsFixed(1)} km de la zone."
            : "";

        showTextModal(
          context,
          "Attention",
          "Tu es hors de la zone de l'évènement. Déplace-toi dans la zone pour continuer.\n\n$distanceText",
          showConfirmButton: true, // Add OK button
        );
        log("User is not in the zone");
      }
    } else {
      showTextModal(
        context,
        "Autorisation requise",
        "La localisation est désactivée. Active-la dans tes paramètres pour continuer.",
        showConfirmButton: true, // Add OK button
      );
      log("Location permission not granted");
    }

    setState(() {
      _isLoading = false; // Set loading state to false
    });

    log("4");
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          SingleChildScrollView(
            // Make the full page scrollable
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  const SizedBox(height: 90), // Add margin at the top
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: const Image(
                          image: AssetImage(
                              'assets/pictures/DrawPosition-removebg.png')),
                    ),
                  ),
                  const SizedBox(height: 32), // Add margin after the logo
                  InfoCard(
                    title: "Préparez vous",
                    data: "Rendez-vous au point de départ de l'évènement.",
                    actionItems: [
                      ActionItem(
                        icon: const Icon(Icons.map,
                            color: Color(Config.COLOR_APP_BAR), size: 32),
                        label: 'Carte',
                        onPressed: () => _showMapModal(context),
                      ),
                      ActionItem(
                        icon: const Icon(Icons.directions,
                            color: Color(Config.COLOR_APP_BAR), size: 32),
                        label: 'Maps',
                        onPressed: _openInGoogleMaps,
                      ),
                      ActionItem(
                        icon: const Icon(Icons.copy_rounded,
                            color: Color(Config.COLOR_APP_BAR), size: 32),
                        label: 'Copier',
                        onPressed: _copyCoordinates,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Add margin between cards
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      'Appuie sur \'Suivant\' quand tu es sur le lieu de l\'évènement',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(Config.COLOR_APP_BAR),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Add margin between cards
                  const SizedBox(
                      height:
                          100), // Add more margin at the bottom to allow more scrolling
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft, // Fix the back button at the top
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 10), // Add padding
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Color(Config.COLOR_APP_BAR), size: 32),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment
                .bottomCenter, // Fix the "Suivant" button at the bottom
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 20.0), // Add padding
              child: ActionButton(
                icon: Icons.arrow_forward, // Add icon to "Suivant" button
                text: 'Suivant',
                onPressed: _navigateToSetupTeamScreen, // Update method call
              ),
            ),
          ),
          if (_isLoading) const LoadingScreen(), // Display LoadingScreen
        ],
      ),
    );
  }
}

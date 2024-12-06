import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:geolocator/geolocator.dart'; // Replace location import with geolocator
import '../Utils/config.dart';
import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import '../Utils/Result.dart';
import 'LoadingScreen.dart'; // Add this import
import 'SetupTeamScreen.dart'; // Rename import

import '../API/MeasureController.dart';
import '../Geolocalisation/Geolocation.dart';

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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
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
  }

  void _openInGoogleMaps() async {
    const url = 'geo:${Config.LAT1},${Config.LON1}?q=${Config.LAT1},${Config.LON1}';
    await launch(url);
  }

  void _copyCoordinates() {
    const coordinates = '${Config.LAT1}, ${Config.LON1}';
    Clipboard.setData(const ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Les coordonnées ont été copiées dans le presse-papiers.')),
    );
  }

  void _showMapModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make background transparent
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 1, // Increase height to take more space
          margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0), // Add margin left and right
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0), // Add rounded borders
            boxShadow: [
              // Add box shadow
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 5.0,
                offset: Offset(0, 5),
              ),
            ],
            color: Colors.white, // Set the color of the container to white
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0), // Clip the map to rounded borders
            child: Stack(
              children: [
                FlutterMap(
                  mapController: MapController(),
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: LatLngBounds(
                        const LatLng(Config.LAT1, Config.LON1),
                        LatLng(_currentPosition?.latitude ?? Config.LAT1, _currentPosition?.longitude ?? Config.LON1),
                      ),
                      padding: const EdgeInsets.all(50.0), // Increase padding to zoom out more
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        const Marker(
                          point: LatLng(Config.LAT1, Config.LON1), // Updated coordinates
                          child: Icon(Icons.place, color: Color(Config.COLOR_BUTTON), size: 48), // Increase icon size
                        ),
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            child: const Icon(Icons.my_location,
                                color: Color(Config.COLOR_APP_BAR), size: 48), // Increase icon size
                          ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black, size: 32),
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
    // Rename method
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    bool canStartNewMeasure = true;
    if (await MeasureController.isThereAMeasure()) {
      Result result = await MeasureController.stopMeasure();
      canStartNewMeasure = !result.hasError;
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
            MaterialPageRoute(builder: (context) => const SetupTeamScreen()), // Rename class
          );
        }
      } else {
        showInSnackBar("Vous n'êtes pas dans la zone");
        log("You are not in the zone");
      }
    } else {
      showInSnackBar("Vous n'avez pas autorisé la localisation");
      log("You did not allow location");
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
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  const SizedBox(height: 90), // Add margin at the top
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: const Image(image: AssetImage('assets/pictures/DrawPosition-removebg.png')),
                    ),
                  ),
                  const SizedBox(height: 60), // Add margin after the logo
                  InfoCard(
                    title: "Préparez vous",
                    data: "Rendez-vous au point de départ de l'évènement.",
                    actionItems: [
                      ActionItem(
                        icon: const Icon(Icons.map, color: Color(Config.COLOR_APP_BAR), size: 32),
                        label: 'Carte',
                        onPressed: () => _showMapModal(context),
                      ),
                      ActionItem(
                        icon: const Icon(Icons.directions, color: Color(Config.COLOR_APP_BAR), size: 32),
                        label: 'Maps',
                        onPressed: _openInGoogleMaps,
                      ),
                      ActionItem(
                        icon: const Icon(Icons.copy_rounded, color: Color(Config.COLOR_APP_BAR), size: 32),
                        label: 'Copier',
                        onPressed: _copyCoordinates,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Add margin between cards
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
          Align(
            alignment: Alignment.bottomCenter, // Fix the "Suivant" button at the bottom
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0), // Add padding
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

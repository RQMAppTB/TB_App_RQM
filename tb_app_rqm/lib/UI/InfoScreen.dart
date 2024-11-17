import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tb_app_rqm/API/DistanceController.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

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
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

/// State of the InfoScreen class.
class _InfoScreenState extends State<InfoScreen> {
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

  /// Number of participants
  int? _numberOfParticipants;

  /// Boolean to check if the start button is enabled
  bool _enabledStart = true;

  int _currentPage = 0;
  final PageController _pageController = PageController();

  /// Function to show a snackbar with the message [value]
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text(value)));
  }

  /// Function to update the remaining time every second
  void countDown() {
    DateTime now = DateTime.now();
    Duration remaining = end.difference(now);
    if (remaining.isNegative) {
      _timer?.cancel();
      setState(() {
        _enabledStart = false;
        _remainingTime = "L'évènement est terminé !";
      });
      return;
    } else if (now.isBefore(start)) {
      setState(() {
        _enabledStart = false;
        _remainingTime = "L'évènement n'a pas encore commencé !";
      });
      return;
    }

    setState(() {
      _remainingTime = '${remaining.inHours}:${(remaining.inMinutes) % 60}:${(remaining.inSeconds) % 60}';
    });
  }

  /// Function to get the value from the API [fetchVal]
  /// and if it fails, get the value from the shared preferences [getVal]
  /// Returns the value
  /// If the value is not found, returns -1
  Future<int> _getValue(Future<Result<int>> Function() fetchVal, Future<int?> Function() getVal) {
    return fetchVal().then((value) {
      if (value.hasError) {
        throw Exception("Could not fetch value because : ${value.error}");
      } else {
        log("Value: ${value.value}");
        return value.value!;
      }
    }).onError((error, stackTrace) {
      log('Error here: $error');
      return getVal().then((value) {
        if (value == null) {
          log("No value");
          return -1;
        } else {
          return value;
        }
      });
    });
  }

  /// Function to calculate the percentage of remaining time
  double _calculateRemainingTimePercentage() {
    Duration totalDuration = end.difference(start);
    Duration elapsed = DateTime.now().difference(start);
    return elapsed.inSeconds / totalDuration.inSeconds * 100;
  }

  /// Function to calculate the percentage of total distance
  double _calculateTotalDistancePercentage() {
    // Assuming 2000000 meters (2M meters) as the target total distance for the event
    const int targetDistance = 2000000;
    return (_distanceTotale ?? 0) / targetDistance * 100;
  }

  @override
  void initState() {
    super.initState();

    // Check if the event has started or ended
    if (DateTime.now().isAfter(end) || DateTime.now().isBefore(start)) {
      _enabledStart = false;
      _remainingTime = "L'évènement ${DateTime.now().isAfter(end) ? "est terminé" : "n'a pas encore commencé"} !";
    } else {
      Geolocation.handlePermission().then((value) {
        if (!value) {
          log('Location permission not granted');
          exit(0);
        } else {
          log('Location permission granted');
        }
      }).onError((error, stackTrace) {
        log('Error: $error');
        exit(0);
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => countDown());
    }

    // Get the total distance
    _getValue(DistanceController.getTotalDistance, DistTotaleData.getDistTotale).then((value) => setState(() {
          _distanceTotale = value;
        }));

    // Get the personal distance
    _getValue(DistanceController.getPersonalDistance, DistPersoData.getDistPerso).then((value) => setState(() {
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

    // Fake the number of participants
    setState(() {
      _numberOfParticipants = 150; // Set a fake number of participants
    });
  }

  @override
  void dispose() {
    log("Dispose");
    _timer?.cancel();
    super.dispose();
  }

  /// Function to go to the configuration screen
  Future<void> _startMeasure() async {
    log("Start measure");
    setState(() {
      _enabledStart = false;
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
            MaterialPageRoute(builder: (context) => const ConfigScreen()),
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

    log("4");
    setState(() {
      _enabledStart = true;
    });
  }

  /// Reusable card widget
  Widget _buildInfoCard(String title, String value, double percentage) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(Config.COLOR_APP_BAR).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 24.0, left: 16.0, right: 32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24), // Add spacing between title and value
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Color(Config.COLOR_APP_BAR)),
                    ),
                  ),
                ],
              ),
            ),
            SimpleCircularProgressBar(
              size: 120,
              progressStrokeWidth: 18,
              backStrokeWidth: 20,
              progressColors: [Color(Config.COLOR_BUTTON)],
              mergeMode: true,
              onGetText: (double value) {
                return Text(
                  '${value.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 24),
                );
              },
              valueNotifier: ValueNotifier(percentage),
            ),
          ],
        ),
      ),
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
        backgroundColor: const Color(Config.COLOR_BACKGROUND),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0), // Add margin
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                  children: <Widget>[
                    const SizedBox(height: 30), // Add margin at the top
                    Center(
                      child: Image(image: AssetImage('assets/pictures/LogoText.png')),
                    ),
                    const SizedBox(height: 20), // Add margin below the logo
                    Text(
                      _currentPage == 0 ? 'Greeting' : 'Event Info',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(Config.COLOR_APP_BAR), // Add color
                      ),
                    ),
                    const SizedBox(height: 10), // Add margin below the title
                    Expanded(
                      flex: 12,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          Container(
                            width: double.infinity, // Full width
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Color(Config.COLOR_BUTTON).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bonjour N°$_dossard : $_name'),
                                Text('Vous avez parcouru ${_distancePerso ?? 0} mètres'),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _buildInfoCard(
                                        'Temps restant',
                                        _remainingTime,
                                        _calculateRemainingTimePercentage(),
                                      ),
                                      const SizedBox(height: 20), // Add margin between sections
                                      _buildInfoCard(
                                        'Distance totale parcourue',
                                        '${_distanceTotale ?? 0} m',
                                        _calculateTotalDistancePercentage(),
                                      ),
                                      const SizedBox(height: 20), // Add margin between sections
                                      _buildInfoCard(
                                        'Nombre de participants',
                                        '${_numberOfParticipants ?? 0}',
                                        1000.0, // Assuming 100% as we don't have a target number for participants
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(), // Add spacer to push the button to the bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 2; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == i ? Colors.blue : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20), // Add margin below the dots
                    Container(
                      width: double.infinity, // Full width
                      decoration: BoxDecoration(
                        color: Color(Config.COLOR_BUTTON).withOpacity(1), // 100% opacity
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () async {
                          _enabledStart ? await _startMeasure() : null;
                        },
                        child: const Text(
                          'Start',
                          style: TextStyle(color: Colors.white, fontSize: 20), // Increase font size
                        ),
                      ),
                    ),
                    const SizedBox(height: 30), // Add margin below the button
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(color: Color(Config.COLOR_APP_BAR), Icons.logout),
                onPressed: () {
                  LoginController.logout().then((result) {
                    if (result.hasError) {
                      showInSnackBar("Please try again later");
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

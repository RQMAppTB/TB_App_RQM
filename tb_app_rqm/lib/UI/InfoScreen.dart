import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lrqm/API/DistanceController.dart';
import 'Components/ProgressCard.dart';
import 'Components/InfoCard.dart';
import 'LoadingPage.dart';
import 'Components/Dialog.dart';
import 'Components/ActionButton.dart';
import 'Components/TopAppBar.dart';

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
import '../Data/NbPersonData.dart';
import '../Data/TimeData.dart';

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
class _InfoScreenState extends State<InfoScreen> with SingleTickerProviderStateMixin {
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

  IconData _selectedIcon = Icons.face;

  final GlobalKey iconKey = GlobalKey();

  int? _tempsPerso;

  final ScrollController _parentScrollController = ScrollController();

  void _showIconMenu(BuildContext context) {
    final List<IconData> icons = [
      Icons.face,
      Icons.face_2,
      Icons.face_3,
      Icons.face_4,
      Icons.face_5,
      Icons.face_6,
    ];

    final List<Widget> iconWidgets = icons.map((icon) {
      return Icon(icon, size: 40, color: Color(Config.COLOR_APP_BAR));
    }).toList();

    CustomDialog.showCustomDialog(
      context,
      'Choisis ton avatar !',
      iconWidgets,
      (selectedItem) {
        setState(() {
          _selectedIcon = (selectedItem as Icon).icon!;
        });
      },
    );
  }

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
      _remainingTime =
          '${remaining.inHours.toString().padLeft(2, '0')}h ${(remaining.inMinutes % 60).toString().padLeft(2, '0')}m ${(remaining.inSeconds % 60).toString().padLeft(2, '0')}s';
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

    // Get the number of participants
    NbPersonData.getNbPerson().then((value) => setState(() {
          _numberOfParticipants = value;
        }));

    // Get the time spent on the track
    TimeData.getTime().then((value) => setState(() {
          _tempsPerso = value;
        }));
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingPage();
      },
    );

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
          Navigator.pop(context); // Close the loading dialog
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConfigScreen()),
          );
        }
      } else {
        Navigator.pop(context); // Close the loading dialog
        showInSnackBar("Vous n'êtes pas dans la zone");
        log("You are not in the zone");
      }
    } else {
      Navigator.pop(context); // Close the loading dialog
      showInSnackBar("Vous n'avez pas autorisé la localisation");
      log("You did not allow location");
    }

    log("4");
    setState(() {
      _enabledStart = true;
    });
  }

  Widget _buildPageViewContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
      child: Column(
        children: [
          InfoCard(
            logo: GestureDetector(
              key: iconKey,
              onTap: () => _showIconMenu(context),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(Config.COLOR_APP_BAR).withOpacity(0.2),
                child: Icon(_selectedIcon, size: 40),
              ),
            ),
            title: 'N°$_dossard',
            data: '$_name',
          ),
          const SizedBox(height: 24),
          InfoCard(
            logo: Image.asset(
              'assets/pictures/LogoSimple.png',
              width: 32, // Adjust the width as needed
              height: 32, // Adjust the height as needed
            ),
            title: 'Distance parcourue',
            data: '${_distancePerso ?? 0} mètres',
            additionalDetails:
                "C'est ${((_distancePerso ?? 0) / Config.CIRCUIT_SIZE).toStringAsFixed(1)} fois le tour du circuit, continue comme ça !",
            progressValue: double.parse(
                ((_distancePerso ?? 0) / Config.CIRCUIT_SIZE).toStringAsFixed(1)), // Progress based on circuit size
          ),
          const SizedBox(height: 12),
          InfoCard(
            logo: Icon(Icons.timer_outlined),
            title: 'Temps passé sur le parcours',
            data: _tempsPerso != null
                ? '${(_tempsPerso! ~/ 3600).toString().padLeft(2, '0')}h ${((_tempsPerso! % 3600) ~/ 60).toString().padLeft(2, '0')}m ${(_tempsPerso! % 60).toString().padLeft(2, '0')}s'
                : '00h 00m 00s',
          ),
          const SizedBox(height: 12),
          InfoCard(
            logo: Icon(Icons.people),
            title: 'Nombre de personnes',
            data: '${_numberOfParticipants ?? 0}',
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
        // Scroll to the top of the parent scroll view instantly when the page changes
        _parentScrollController.jumpTo(0.0);
      },
      children: [
        _buildPageViewContent(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding here
          child: Column(
            children: [
              ProgressCard(
                title: 'Temps restant',
                value: _remainingTime,
                percentage: _calculateRemainingTimePercentage(),
                logo: Icon(Icons.timer_outlined),
              ),
              const SizedBox(height: 12),
              ProgressCard(
                title: 'Distance totale parcourue',
                value: '${_distanceTotale ?? 0} m',
                percentage: _calculateTotalDistancePercentage(),
                logo: Image.asset(
                  'assets/pictures/LogoSimple.png',
                  width: 32, // Adjust the width as needed
                  height: 32, // Adjust the height as needed
                ),
              ),
              const SizedBox(height: 12),
              InfoCard(
                logo: Icon(Icons.people),
                title: 'Nombre de participants',
                data: '150',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey iconKey = GlobalKey();

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        log("Trying to pop");
      },
      child: Scaffold(
        backgroundColor: const Color(Config.COLOR_BACKGROUND),
        appBar: const TopAppBar(title: 'Informations', showInfoButton: true),
        body: Stack(
          children: [
            Container(
              color: Color(Config.COLOR_BACKGROUND), // Set background color
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  const SizedBox(height: 30), // Add margin at the top
                  // Remove the logo text from the screen
                  // const SizedBox(height: 35), // Add margin below the logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Informations ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Color(Config.COLOR_APP_BAR),
                            ),
                          ),
                          TextSpan(
                            text: _currentPage == 0 ? 'personnelles' : 'sur l\'évènement',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(Config.COLOR_APP_BAR),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 12,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0), // Adjust padding for PageView
                      child: SingleChildScrollView(
                        controller: _parentScrollController,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
                          child: _buildPageView(),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(), // Add spacer to push the button to the bottom
                  Container(
                    child: Column(
                      children: [
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
                                  color: _currentPage == i
                                      ? Color(Config.COLOR_APP_BAR)
                                      : Color(Config.COLOR_APP_BAR).withOpacity(0.1),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16), // Add margin below the dots
                        Container(
                          color: Colors.white, // Set background color to white
                          child: Column(
                            children: [
                              const SizedBox(height: 12), // Add margin between dots and start button
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin for Start button
                                child: ActionButton(
                                  icon: Icons.play_arrow_outlined,
                                  text: 'START',
                                  onPressed: () async {
                                    _enabledStart ? await _startMeasure() : null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20), // Add margin below the button
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

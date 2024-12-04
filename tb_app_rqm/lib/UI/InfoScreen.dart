import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lrqm/API/DistanceController.dart';
import 'Components/ProgressCard.dart';
import 'Components/InfoCard.dart';
import 'Components/Dialog.dart';
import 'Components/ActionButton.dart';
import 'Components/TopAppBar.dart';
import 'SetupPosScreen.dart'; // Add this import
import 'package:lrqm/Data/DataManagement.dart';
import 'package:lrqm/Data/Session.dart';

import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Data/DossardData.dart';
import '../Data/NameData.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import '../Data/NbPersonData.dart';
import '../Data/TimeData.dart';
import '../Geolocalisation/Geolocation.dart';
import 'Components/DiscardButton.dart';

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

  int _currentPage = 0;
  final PageController _pageController = PageController();

  IconData _selectedIcon = Icons.face;

  final GlobalKey iconKey = GlobalKey();

  int? _tempsPerso;

  final ScrollController _parentScrollController = ScrollController();

  bool _isSessionActive = false;
  Geolocation _geolocation = Geolocation();
  int _distance = 0;

  void _showIconMenu(BuildContext context) {
    final List<IconData> icons = [
      Icons.face,
      Icons.face_2,
      Icons.face_2,
      Icons.face_3,
      Icons.face_4,
      Icons.face_5,
      Icons.face_6,
    ];

    final List<Widget> iconWidgets = icons.map((icon) {
      return Icon(icon, size: 40, color: const Color(Config.COLOR_APP_BAR));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  /// Function to update the remaining time every second
  void countDown() {
    DateTime now = DateTime.now();
    Duration remaining = end.difference(now);
    if (remaining.isNegative) {
      _timer?.cancel();
      setState(() {
        _remainingTime = "L'évènement est terminé !";
      });
      return;
    } else if (now.isBefore(start)) {
      setState(() {
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
    return (_distanceTotale ?? 0) / Config.TARGET_DISTANCE * 100;
  }

  String _formatDistance(int distance) {
    return distance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}\'');
  }

  @override
  void initState() {
    super.initState();

    // Check if a session is ongoing
    Session.isStarted().then((isOngoing) {
      if (isOngoing) {
        setState(() {
          _isSessionActive = true;
        });
        _geolocation.stream.listen((event) {
          log("Stream event: $event");
          if (event == -1) {
            log("Stream event: $event");
            _geolocation.stopListening();
            Session.stopSession();
            setState(() {
              _isSessionActive = false;
            });
          } else {
            setState(() {
              _distance = event;
            });
          }
        });
        _geolocation.startListening();
      }
    });

    // Check if the event has started or ended
    if (DateTime.now().isAfter(end) || DateTime.now().isBefore(start)) {
      _remainingTime = "L'évènement ${DateTime.now().isAfter(end) ? "est terminé" : "n'a pas encore commencé"} !";
    } else {
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
    _geolocation.stopListening();
    super.dispose();
  }

  /// Function to refresh all values
  void _refreshValues() {
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
          _dossard = value.toString().padLeft(4, '0');
        }));

    // Get the name of the user
    NameData.getName().then((value) => setState(() {
          _name = value;
        }));

    // Get the number of participants
    NbPersonData.getNbPerson().then((value) => setState(() {
          _numberOfParticipants = value;
        }));

    // Get the time spent on the track
    TimeData.getTime().then((value) => setState(() {
          _tempsPerso = value;
        }));
  }

  void _confirmStopSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Arréter la session en cours ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Oui'),
              onPressed: () async {
                try {
                  await Session.stopSession();
                } catch (e) {
                  await Session.forceStopSession();
                }
                setState(() {
                  _isSessionActive = false;
                });
                _refreshValues(); // Refresh values after stopping the session
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageViewContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
      child: Column(
        children: [
          const SizedBox(height: 8), // Add margin before the first card
          InfoCard(
            logo: GestureDetector(
              key: iconKey,
              onTap: () => _showIconMenu(context),
              child: CircleAvatar(
                radius: 36,
                backgroundColor: const Color(Config.COLOR_APP_BAR).withOpacity(0.2),
                child: Icon(_selectedIcon, size: 40),
              ),
            ),
            title: 'N°$_dossard',
            data: _name,
          ),
          const SizedBox(height: 24),
          InfoCard(
            logo: Image.asset(
              _isSessionActive ? 'assets/pictures/LogoSimpleAnimated.gif' : 'assets/pictures/LogoSimple.png',
              width: _isSessionActive ? 40 : 32, // Adjust the width as needed
              height: _isSessionActive ? 40 : 32, // Adjust the height as needed
            ),
            title: 'Distance parcourue',
            data: '${_formatDistance(_isSessionActive ? _distance : (_distancePerso ?? 0))} mètres',
            additionalDetails:
                "C'est ${((_isSessionActive ? _distance : (_distancePerso ?? 0)) / Config.CIRCUIT_SIZE).toStringAsFixed(1)} fois le tour du circuit, continue comme ça !",
          ),
          const SizedBox(height: 12),
          InfoCard(
            logo: const Icon(Icons.timer_outlined),
            title: 'Temps passé sur le parcours',
            data: _tempsPerso != null
                ? '${(_tempsPerso! ~/ 3600).toString().padLeft(2, '0')}h ${((_tempsPerso! % 3600) ~/ 60).toString().padLeft(2, '0')}m ${(_tempsPerso! % 60).toString().padLeft(2, '0')}s'
                : '00h 00m 00s',
          ),
          const SizedBox(height: 12),
          InfoCard(
            logo: const Icon(Icons.people),
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
              const SizedBox(height: 8), // Add margin before the first card
              ProgressCard(
                title: 'Temps restant',
                value: _remainingTime,
                percentage: _calculateRemainingTimePercentage(),
                logo: const Icon(Icons.timer_outlined),
              ),
              const SizedBox(height: 12),
              ProgressCard(
                title: 'Distance totale parcourue',
                value: '${_formatDistance(_distanceTotale ?? 0)} m',
                percentage: _calculateTotalDistancePercentage(),
                logo: Image.asset(
                  'assets/pictures/LogoSimple.png',
                  width: 32, // Adjust the width as needed
                  height: 32, // Adjust the height as needed
                ),
              ),
              const SizedBox(height: 12),
              const InfoCard(
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
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        log("Trying to pop");
      },
      child: Scaffold(
        backgroundColor: const Color(Config.COLOR_BACKGROUND),
        appBar: TopAppBar(
          title: 'Informations',
          showInfoButton: true,
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.white, // Set background color
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  const SizedBox(height: 24), // Add margin at the top
                  // Remove the logo text from the screen
                  // const SizedBox(height: 35), // Add margin below the logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Informations ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Color(Config.COLOR_APP_BAR),
                            ),
                          ),
                          TextSpan(
                            text: _currentPage == 0 ? 'personnelles' : 'sur l\'évènement',
                            style: const TextStyle(
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
                  const SizedBox(height: 8),
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
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < 2; i++)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              width: 32.0, // Width for oval shape
                              height: 6.0, // Height for oval shape
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0), // Border radius for oval shape
                                color: _currentPage == i
                                    ? const Color(Config.COLOR_APP_BAR)
                                    : const Color(Config.COLOR_APP_BAR).withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20), // Add margin below the dots
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white, // Set background color to white
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin for Start button
                              child: _isSessionActive
                                  ? DiscardButton(
                                      text: 'STOP',
                                      icon: Icons.stop, // Pass the icon parameter
                                      onPressed: () {
                                        _confirmStopSession(context);
                                      },
                                    )
                                  : ActionButton(
                                      icon: Icons.play_arrow_outlined,
                                      text: 'START',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const SetupPosScreen()),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 20), // Add margin below the button
                          ],
                        ),
                      ),
                    ],
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

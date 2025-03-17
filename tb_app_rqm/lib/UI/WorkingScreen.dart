import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'Components/ProgressCard.dart';
import 'Components/InfoCard.dart';
import 'Components/Dialog.dart';
import 'Components/ActionButton.dart';
import 'Components/TopAppBar.dart';
import 'Components/TitleCard.dart';
import 'Components/DiscardButton.dart';
import 'Components/InfoDialog.dart';

import 'SetupPosScreen.dart';
import 'LoadingScreen.dart';

import '../Utils/Result.dart';
import '../Utils/config.dart';
import '../Data/TimeData.dart';
import '../Geolocalisation/Geolocation.dart';

import '../API/NewEventController.dart';
import '../API/NewUserController.dart';
import '../API/NewMeasureController.dart';

import '../Data/EventData.dart';
import '../Data/UserData.dart';
import '../Data/MeasureData.dart';
import '../Data/ContributorsData.dart'; // Import ContributorsData

/// Class to display the working screen.
/// This screen displays the remaining time before the end of the event,
/// the total distance traveled by all participants,
/// the distance traveled by the current participant,
/// the dossard number and the name of the user.
class WorkingScreen extends StatefulWidget {
  const WorkingScreen({super.key});

  @override
  State<WorkingScreen> createState() => _WorkingScreenState();
}

/// State of the WorkingScreen class.
class _WorkingScreenState extends State<WorkingScreen>
    with SingleTickerProviderStateMixin {
  /// Timer to update the remaining time every second
  Timer? _timer;

  /// Start time of the event
  DateTime? start;

  /// End time of the event
  DateTime? end;

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

  /// Number of participants
  int? _contributors;

  int _currentPage = 0;
  final PageController _pageController = PageController();

  IconData _selectedIcon = Icons.face;

  final GlobalKey iconKey = GlobalKey();

  int? _sessionTimePerso;
  int? _totalTimePerso;

  final ScrollController _parentScrollController = ScrollController();

  bool _isMeasureActive = false;
  Geolocation _geolocation = Geolocation();
  int _distance = 0;

  /// Event meters goal
  int? _metersGoal;

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
    if (start == null || end == null) return;

    DateTime now = DateTime.now();
    Duration remaining = end!.difference(now);
    if (remaining.isNegative) {
      _timer?.cancel();
      if (mounted) {
        setState(() {
          _remainingTime = "L'évènement est terminé !";
        });
      }
      return;
    } else if (now.isBefore(start!)) {
      if (mounted) {
        setState(() {
          _remainingTime = "L'évènement n'a pas encore commencé !";
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _remainingTime =
            '${remaining.inHours.toString().padLeft(2, '0')}h ${(remaining.inMinutes % 60).toString().padLeft(2, '0')}m ${(remaining.inSeconds % 60).toString().padLeft(2, '0')}s';
      });
    }
  }

  /// Function to get the value from the API [fetchVal]
  /// and if it fails, get the value from the shared preferences [getVal]
  /// Returns the value
  /// If the value is not found, returns -1
  Future<int> _getValue(
      Future<Result<int>> Function() fetchVal, Future<int?> Function() getVal) {
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
    if (start == null || end == null) return 0.0;

    Duration totalDuration = end!.difference(start!);
    Duration elapsed = DateTime.now().difference(start!);
    return elapsed.inSeconds / totalDuration.inSeconds * 100;
  }

  /// Function to calculate the percentage of total distance
  double _calculateTotalDistancePercentage() {
    return (_distanceTotale ?? 0) / Config.TARGET_DISTANCE * 100;
  }

  /// Function to calculate the percentage of total distance based on event meters goal
  double _calculateRealProgress() {
    if (_metersGoal == null || _metersGoal == 0) return 0.0;
    return (_distanceTotale ?? 0) / _metersGoal! * 100;
  }

  String _formatDistance(int distance) {
    return distance.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}\'');
  }

  String _getDistanceMessage(int distance) {
    if (distance <= 100) {
      return "C'est ${(distance / 0.2).toStringAsFixed(0)} saucisse aux choux mis bout à bout. Quel papet! Continue comme ça";
    } else if (distance <= 4000) {
      return "C'est ${(distance / 400).toStringAsFixed(1)} tour(s) de la piste de la pontaise. Trop fort!";
    } else if (distance <= 38400) {
      return "C'est ${(distance / 12800).toStringAsFixed(1)} fois la distance Bottens-Lausanne. Tu es un champion, n'oublie pas de boire!";
    } else {
      return "C'est ${(distance / 42195).toStringAsFixed(1)} marathon. Tu as une forme et une détermination fantastique. Pense à reprendre des forces";
    }
  }

  @override
  void initState() {
    super.initState();

    // Retrieve the event start and end times
    EventData.getStartDate().then((startDate) {
      if (startDate != null && mounted) {
        setState(() {
          start = DateTime.parse(startDate);
        });
      }
    });

    EventData.getEndDate().then((endDate) {
      if (endDate != null && mounted) {
        setState(() {
          end = DateTime.parse(endDate);
        });
      }
    });

    // Retrieve the bib_id from UserData
    UserData.getBibId().then((bibId) {
      if (bibId != null && mounted) {
        setState(() {
          _dossard = bibId;
        });

        // Get the personal distance
        _getValue(() => NewUserController.getUserTotalMeters(int.parse(bibId)),
            () async => null).then((value) {
          if (mounted) {
            setState(() {
              _distancePerso = value;
            });
          }
        });

        // Get the total time
        _getValue(() => NewUserController.getUserTotalTime(int.parse(bibId)),
            () async => null).then((value) {
          if (mounted) {
            setState(() {
              _totalTimePerso = value;
            });
          }
        });

        // Get the name of the user
        UserData.getUsername().then((username) {
          if (username != null && mounted) {
            setState(() {
              _name = username;
            });
          } else {
            log("Failed to fetch username from UserData.");
          }
        });
      } else {
        log("Bib ID not found in UserData.");
      }
    });

    // Check if a measure is ongoing
    MeasureData.isMeasureOngoing().then((isOngoing) {
      if (isOngoing && mounted) {
        setState(() {
          _isMeasureActive = true;
        });
        _geolocation.stream.listen((event) {
          log("Stream event: $event");
          if (event["distance"] == -1) {
            log("Stream event: $event");
            _geolocation.stopListening();
            NewMeasureController.stopMeasure();
            if (mounted) {
              setState(() {
                _isMeasureActive = false;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                _distance = event["distance"] ?? 0;
                _sessionTimePerso = event["time"];
              });
            }
          }
        });
        _geolocation.startListening();
      } else {
        // Get the total time spent on the track
        UserData.getBibId().then((bibId) {
          if (bibId != null) {
            NewUserController.getUserTotalTime(int.parse(bibId)).then((result) {
              if (!result.hasError && mounted) {
                setState(() {
                  _totalTimePerso = result.value;
                });
              }
            });
          }
        });
      }
    });

    // Check if the event has started or ended
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (start != null && end != null) {
        countDown();
      }
    });

    // Get the event ID
    EventData.getEventId().then((eventId) {
      if (eventId != null && mounted) {
        // Get the total distance
        _getValue(() => NewEventController.getTotalMeters(eventId),
            () async => null).then((value) {
          if (mounted) {
            setState(() {
              _distanceTotale = value;
            });
          }
        });

        // Get the number of participants
        NewEventController.getActiveUsers(eventId).then((result) {
          if (!result.hasError && mounted) {
            setState(() {
              _numberOfParticipants = result.value;
            });
          }
        });
      } else {
        log("Failed to fetch event ID from EventData.");
      }
    });

    // Retrieve the number of contributors
    ContributorsData.getContributors().then((contributors) {
      if (contributors != null && mounted) {
        setState(() {
          _contributors = contributors;
        });
      }
    });

    // Retrieve the event meters goal
    EventData.getMetersGoal().then((metersGoal) {
      if (metersGoal != null && mounted) {
        setState(() {
          _metersGoal = metersGoal;
        });
      }
    });
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
    // Retrieve the bib_id from UserData
    UserData.getBibId().then((bibId) {
      if (bibId != null) {
        setState(() {
          _dossard = bibId;
        });

        // Get the personal distance
        _getValue(
                () => NewUserController.getUserTotalMeters(int.parse(bibId)), () async => null)
            .then((value) => setState(() {
                  _distancePerso = value;
                }));

        // Get the name of the user
        UserData.getUsername().then((username) {
          if (username != null) {
            setState(() {
              _name = username;
            });
          } else {
            log("Failed to fetch username from UserData.");
          }
        });
      } else {
        log("Bib ID not found in UserData.");
      }
    });

    // Get the event ID
    EventData.getEventId().then((eventId) {
      if (eventId != null) {
        // Get the total distance
        _getValue(
                () => NewEventController.getTotalMeters(eventId), () async => null)
            .then((value) => setState(() {
                  _distanceTotale = value;
                }));

        // Get the number of participants
        NewEventController.getActiveUsers(eventId).then((result) {
          if (!result.hasError) {
            setState(() {
              _numberOfParticipants = result.value;
            });
          }
        });
      } else {
        log("Failed to fetch event ID from EventData.");
      }
    });

    // Get the time spent on the track
    UserData.getBibId().then((bibId) {
      if (bibId != null) {
        NewUserController.getUserTotalTime(int.parse(bibId)).then((result) {
          if (!result.hasError && mounted) {
            setState(() {
              _totalTimePerso = result.value;
            });
          }
        });
      }
    });
  }

  void _confirmStopMeasure(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return InfoDialog(
          title: 'Confirmation',
          content: 'Arrêter la mesure en cours ?',
          onYes: () async {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const LoadingScreen(text: 'On se repose un peu...'),
              ),
            );
            try {
              _geolocation
                  .stopListening(); // Ensure geolocation stops listening
              await NewMeasureController.stopMeasure();
            } catch (e) {
              log("Failed to stop measure: $e");
            }
            setState(() {
              _isMeasureActive = false;
            });
            _refreshValues(); // Refresh values after stopping the measure
            Navigator.of(context).pop(); // Close the loading screen
            Navigator.of(context).pop(); // Close the confirmation dialog
          },
          onNo: () {
            Navigator.of(context).pop();
          },
          logo: const Icon(Icons.warning_outlined,
              color: Color(Config.COLOR_APP_BAR)), // Add optional logo
        );
      },
    );
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    int displayedTime =
        _isMeasureActive ? (_sessionTimePerso ?? 0) : (_totalTimePerso ?? 0);

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
          isRecording: _isMeasureActive, // Pass recording status
        ),
        body: Stack(
          children: [
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! < 0) {
                  // Swiped left
                  setState(() {
                    _currentPage = (_currentPage + 1) % 2;
                    _animateToPage(_currentPage);
                  });
                } else if (details.primaryVelocity! > 0) {
                  // Swiped right
                  setState(() {
                    _currentPage = (_currentPage - 1 + 2) % 2;
                    _animateToPage(_currentPage);
                  });
                }
              },
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  SingleChildScrollView(
                    // Make the full page scrollable
                    controller: _parentScrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align text to the left
                        children: <Widget>[
                          const SizedBox(height: 16), // Add margin at the top
                          const TitleCard(
                            icon: Icons.person,
                            title: 'Informations ',
                            subtitle: 'personnelles',
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              InfoCard(
                                logo: GestureDetector(
                                  onTap: () => _showIconMenu(context),
                                  child: Icon(_selectedIcon),
                                ),
                                title: '№ de dossard: $_dossard',
                                data: _name,
                              ),
                              const SizedBox(height: 6),
                              InfoCard(
                                logo: Image.asset(
                                  _isMeasureActive
                                      ? 'assets/pictures/LogoSimpleAnimated.gif'
                                      : 'assets/pictures/LogoSimple.png',
                                  width: _isMeasureActive ? 32 : 26,
                                  height: _isMeasureActive ? 32 : 26,
                                ),
                                title: _isMeasureActive
                                    ? 'Distance parcourue'
                                    : 'Contribution à l\'évènement',
                                data:
                                    '${_formatDistance(_isMeasureActive ? _distance : (_distancePerso ?? 0))} mètres',
                                additionalDetails: _getDistanceMessage(
                                    _isMeasureActive
                                        ? _distance
                                        : (_distancePerso ?? 0)),
                              ),
                              const SizedBox(height: 6),
                              InfoCard(
                                logo: const Icon(Icons.timer_outlined),
                                title: _isMeasureActive
                                    ? 'Temps passé sur le parcours'
                                    : 'Temps total passé sur le parcours',
                                data:
                                    '${(displayedTime ~/ 3600).toString().padLeft(2, '0')}h ${((displayedTime % 3600) ~/ 60).toString().padLeft(2, '0')}m ${(displayedTime % 60).toString().padLeft(2, '0')}s',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (_isMeasureActive)
                            InfoCard(
                              logo: const Icon(Icons.groups_2),
                              title: 'L\'équipe',
                              data:
                                  '${_contributors ?? 0}', // Use contributors data
                            )
                          else if (!_isMeasureActive)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                'Appuie sur START pour démarrer une mesure',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(Config.COLOR_APP_BAR),
                                ),
                              ),
                            ),
                          const SizedBox(
                              height: 16), // AdAd margin before the text
                          const SizedBox(
                              height:
                                  100), // Add more margin at the bottom to allow more scrolling
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    // Make the full page scrollable
                    controller: _parentScrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align text to the left
                        children: <Widget>[
                          const SizedBox(height: 16), // Add margin at the top
                          const TitleCard(
                            icon: Icons.calendar_month,
                            title: 'Informations sur',
                            subtitle: 'l\'évènement',
                          ),
                          const SizedBox(height: 16),
                          ProgressCard(
                            title: 'Objectif',
                            value:
                                '${_formatDistance(_distanceTotale ?? 0)} m (${_formatDistance(_metersGoal ?? 0)} m)',
                            percentage: _calculateRealProgress(),
                            logo: Image.asset(
                              'assets/pictures/LogoSimple.png',
                              width: 28, // Adjust the width as needed
                              height: 28, // Adjust the height as needed
                            ),
                          ),
                          const SizedBox(height: 6),
                          ProgressCard(
                            title: 'Temps restant',
                            value: _remainingTime,
                            percentage: _calculateRemainingTimePercentage(),
                            logo: const Icon(Icons.timer_outlined),
                          ),
                          const SizedBox(height: 6),
                          ProgressCard(
                            title:
                                'Participants ou groupe actuellement sur le parcours',
                            value: '${_numberOfParticipants ?? 0}',
                            percentage: ((_numberOfParticipants ?? 0) /
                                    250 *
                                    100)
                                .clamp(0,
                                    100), // Calculate percentage with max 250
                            logo: const Icon(Icons.groups_2),
                          ),
                          const SizedBox(height: 6),
                          const SizedBox(
                              height:
                                  100), // Add more margin at the bottom to allow more scrolling
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 2; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          width: 8.0, // Width for oval shape
                          height: 8.0, // Height for oval shape
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(4.0), // Oval shape
                            color: _currentPage == i
                                ? const Color(Config.COLOR_APP_BAR)
                                : const Color(Config.COLOR_APP_BAR)
                                    .withOpacity(0.1),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 12.0)
                        .copyWith(bottom: 20.0), // Add padding
                    child: _isMeasureActive
                        ? DiscardButton(
                            icon: Icons.stop, // Pass the icon parameter
                            text: 'STOP',
                            onPressed: () {
                              _confirmStopMeasure(context);
                            },
                          )
                        : ActionButton(
                            icon: Icons.flag_outlined,
                            text: 'START',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SetupPosScreen()),
                              );
                            },
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

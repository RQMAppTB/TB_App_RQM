import 'package:flutter/material.dart';
import 'Components/TitleCard.dart';
import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import '../Utils/config.dart';
import 'WorkingScreen.dart';

class SummaryScreen extends StatefulWidget {
  final int distanceAdded;
  final int timeAdded;
  final double percentageAdded;
  final int contributors;

  const SummaryScreen({
    Key? key,
    required this.distanceAdded,
    required this.timeAdded,
    required this.percentageAdded,
    required this.contributors,
  }) : super(key: key);

  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _distanceController;
  late Animation<int> _distanceAnimation;

  late AnimationController _contributorsController;
  late Animation<int> _contributorsAnimation;

  late AnimationController _totalDistanceController;
  late Animation<int> _totalDistanceAnimation;

  late AnimationController _eventPercentageController;
  late Animation<double> _eventPercentageAnimation;

  late AnimationController _timeController;
  late Animation<int> _timeAnimation;

  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize controllers and animations for distance
    _distanceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _distanceAnimation = IntTween(begin: 0, end: widget.distanceAdded)
        .animate(CurvedAnimation(parent: _distanceController, curve: Curves.easeOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentCardIndex = 1; // Show the next card
          });
          _contributorsController.forward();
        }
      });

    // Initialize controllers and animations for contributors
    _contributorsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _contributorsAnimation = IntTween(begin: 0, end: widget.contributors)
        .animate(CurvedAnimation(parent: _contributorsController, curve: Curves.easeOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentCardIndex = 2; // Show the next card
          });
          _timeController.forward();
        }
      });

    // Initialize controllers and animations for time
    _timeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _timeAnimation = IntTween(begin: 0, end: widget.timeAdded)
        .animate(CurvedAnimation(parent: _timeController, curve: Curves.easeOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentCardIndex = 3; // Show the next card
          });
          _totalDistanceController.forward();
        }
      });

    // Initialize controllers and animations for total distance
    _totalDistanceController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _totalDistanceAnimation = IntTween(
      begin: 0,
      end: widget.distanceAdded * widget.contributors,
    ).animate(CurvedAnimation(parent: _totalDistanceController, curve: Curves.easeOut))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentCardIndex = 4; // Show the next card
          });
          _eventPercentageController.forward();
        }
      });

    // Initialize controllers and animations for event percentage
    _eventPercentageController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _eventPercentageAnimation = Tween<double>(begin: 0, end: widget.percentageAdded)
        .animate(CurvedAnimation(parent: _eventPercentageController, curve: Curves.easeOut));

    // Start the first animation
    _distanceController.forward();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _contributorsController.dispose();
    _totalDistanceController.dispose();
    _eventPercentageController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  String _formatTime(int timeInSeconds) {
    return '${(timeInSeconds ~/ 3600).toString().padLeft(2, '0')}h ${(timeInSeconds % 3600 ~/ 60).toString().padLeft(2, '0')}m ${(timeInSeconds % 60).toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TitleCard(
                    icon: Icons.check_circle_outline,
                    title: 'Félicitations !',
                    subtitle: 'Résumé de votre contribution',
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _distanceController,
                    builder: (context, child) {
                      return InfoCard(
                        logo: const Icon(Icons.directions_walk, size: 32),
                        title: 'Distance parcourue',
                        data: '${_distanceAnimation.value} mètres',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_currentCardIndex >= 1)
                    AnimatedBuilder(
                      animation: _contributorsController,
                      builder: (context, child) {
                        return InfoCard(
                          logo: const Icon(Icons.groups, size: 32),
                          title: 'Nombre de participants',
                          data: '${_contributorsAnimation.value}',
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  if (_currentCardIndex >= 2)
                    AnimatedBuilder(
                      animation: _timeController,
                      builder: (context, child) {
                        return InfoCard(
                          logo: const Icon(Icons.timer, size: 32),
                          title: 'Durée de la mesure',
                          data: '${_formatTime(_timeAnimation.value)}',
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  if (_currentCardIndex >= 3)
                    const TitleCard(
                      icon: Icons.insights,
                      title: 'Impact collectif',
                      subtitle: 'Votre contribution à l\'évènement',
                    ),
                  const SizedBox(height: 16),
                  if (_currentCardIndex >= 3)
                    AnimatedBuilder(
                      animation: _totalDistanceController,
                      builder: (context, child) {
                        return InfoCard(
                          logo: const Icon(Icons.add_chart, size: 32),
                          title: 'Distance totale ajoutée',
                          data: '+ ${_totalDistanceAnimation.value} mètres',
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  if (_currentCardIndex >= 4)
                    AnimatedBuilder(
                      animation: _eventPercentageController,
                      builder: (context, child) {
                        return InfoCard(
                          logo: const Icon(Icons.pie_chart, size: 32),
                          title: 'Pourcentage de l\'évènement',
                          data: '+ ${_eventPercentageAnimation.value.toStringAsFixed(2)}%',
                        );
                      },
                    ),
                  const SizedBox(height: 100), // Add space for the fixed button
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ActionButton(
                icon: Icons.check,
                text: 'OK',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const WorkingScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import '../Utils/config.dart';
import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import 'ConfigScreen.dart';
import 'LoadingScreen.dart';
import 'Components/ParticipantCard.dart';

class SetupTeamScreen extends StatefulWidget {
  const SetupTeamScreen({super.key});

  @override
  _SetupTeamScreenState createState() => _SetupTeamScreenState();
}

class _SetupTeamScreenState extends State<SetupTeamScreen> {
  bool _isLoading = false;
  int _selectedParticipants = 0;

  void _navigateToConfigScreen() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate some async operation
    await Future.delayed(const Duration(seconds: 2));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfigScreen(nbParticipants: _selectedParticipants),
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  void _selectParticipants(int count) {
    setState(() {
      _selectedParticipants = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(Config.COLOR_APP_BAR), size: 32),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 90),
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: const Image(image: AssetImage('assets/pictures/DrawTeam-removebg.png')),
                    ),
                  ),
                  const SizedBox(height: 52),
                  Expanded(
                    flex: 12,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8.0), // Add margin before the InfoCard
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
                            child: InfoCard(
                              title: "L'équipe !",
                              data: "Pour combien de personnes comptes tu les mètres ?",
                              actionItems: [],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
                            child: Column(
                              children: [
                                ParticipantCard(
                                  logo: Icon(Icons.looks_one, size: 32),
                                  text: "Je pars en solo",
                                  onTap: () => _selectParticipants(1),
                                  isSelected: _selectedParticipants == 1,
                                ),
                                const SizedBox(height: 12),
                                ParticipantCard(
                                  logo: Icon(Icons.looks_two, size: 32),
                                  text: "On fait la paire",
                                  onTap: () => _selectParticipants(2),
                                  isSelected: _selectedParticipants == 2,
                                ),
                                const SizedBox(height: 12),
                                ParticipantCard(
                                  logo: Icon(Icons.looks_3, size: 32),
                                  text: "On se lance en triplettte",
                                  onTap: () => _selectParticipants(3),
                                  isSelected: _selectedParticipants == 3,
                                ),
                                const SizedBox(height: 12),
                                ParticipantCard(
                                  logo: Icon(Icons.looks_4, size: 32),
                                  text: "La monstre équipe",
                                  onTap: () => _selectParticipants(4),
                                  isSelected: _selectedParticipants == 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  ActionButton(
                    icon: Icons.arrow_forward,
                    text: 'Suivant',
                    onPressed: _navigateToConfigScreen,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading) const LoadingScreen(),
        ],
      ),
    );
  }
}

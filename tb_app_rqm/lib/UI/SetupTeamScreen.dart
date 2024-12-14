import 'dart:developer';
import 'package:flutter/material.dart';
import '../Utils/config.dart';
import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import 'SetupScanScreen.dart';
import 'LoadingScreen.dart';
import 'Components/TapCard.dart';
import 'Components/ActionButton.dart';

class SetupTeamScreen extends StatefulWidget {
  const SetupTeamScreen({super.key});

  @override
  _SetupTeamScreenState createState() => _SetupTeamScreenState();
}

class _SetupTeamScreenState extends State<SetupTeamScreen> {
  bool _isLoading = false;
  int _selectedParticipants = 0;

  void _navigateToSetupScanScreen() async {
    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetupScanScreen(nbParticipants: _selectedParticipants),
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
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: const Image(image: AssetImage('assets/pictures/DrawTeam-removebg.png')),
                    ),
                  ),
                  const SizedBox(height: 52),
                  Container(
                    margin: const EdgeInsets.only(top: 8.0), // Add margin before the InfoCard
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
                    child: InfoCard(
                      title: "L'équipe !",
                      data: "Pour combien de personnes comptes-tu les mètres ?",
                      actionItems: [],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add padding to the left and right
                    child: Column(
                      children: [
                        TapCard(
                          logo: Icon(Icons.looks_one, size: 32),
                          text: "Je pars en solo",
                          onTap: () => _selectParticipants(1),
                          isSelected: _selectedParticipants == 1,
                        ),
                        const SizedBox(height: 8),
                        TapCard(
                          logo: Icon(Icons.looks_two, size: 32),
                          text: "On fait la paire",
                          onTap: () => _selectParticipants(2),
                          isSelected: _selectedParticipants == 2,
                        ),
                        const SizedBox(height: 8),
                        TapCard(
                          logo: Icon(Icons.looks_3, size: 32),
                          text: "On se lance en triplettte",
                          onTap: () => _selectParticipants(3),
                          isSelected: _selectedParticipants == 3,
                        ),
                        const SizedBox(height: 8),
                        TapCard(
                          logo: Icon(Icons.looks_4, size: 32),
                          text: "La monstre équipe",
                          onTap: () => _selectParticipants(4),
                          isSelected: _selectedParticipants == 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Add more margin at the bottom to allow more scrolling
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft, // Fix the back button at the top
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 10, right: 10), // Add padding
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(Config.COLOR_APP_BAR), size: 32),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 10), // Add padding between the back button and the text
                  // ...existing code...
                ],
              ),
            ),
          ),
          if (_selectedParticipants > 0 && _selectedParticipants < 5)
            Align(
              alignment: Alignment.bottomCenter, // Fix the "Suivant" button at the bottom
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 20.0), // Add padding
                child: ActionButton(
                  icon: Icons.arrow_forward,
                  text: 'Suivant',
                  onPressed: _navigateToSetupScanScreen,
                ),
              ),
            ),
          if (_isLoading) const LoadingScreen(),
        ],
      ),
    );
  }
}

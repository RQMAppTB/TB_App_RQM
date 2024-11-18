import 'dart:developer';

import 'package:flutter/material.dart';
import '../API/LoginController.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'InfoScreen.dart';
import 'Components/InfoCard.dart';
import 'Components/ActionButton.dart';
import 'Components/DiscardButton.dart';

class ConfirmScreen extends StatelessWidget {
  final String name;
  final int dossard;

  const ConfirmScreen({Key? key, required this.name, required this.dossard}) : super(key: key);

  void showInSnackBar(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  const SizedBox(height: 100), // Add margin at the top
                  Flexible(
                    flex: 3,
                    child: Center(
                      child: Image(image: AssetImage('assets/pictures/question.png')),
                    ),
                  ),
                  const SizedBox(height: 80), // Add margin after the logo
                  Expanded(
                    flex: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start, // Reduce margin
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      children: [
                        InfoCard(
                          logo: CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(Config.COLOR_APP_BAR).withOpacity(0.2),
                            child: Icon(Icons.face, size: 40),
                          ),
                          title: "Est-ce bien toi ?",
                          data: name,
                        ),
                        Spacer(), // Add spacer to push the buttons to the bottom
                        ActionButton(
                          icon: Icons.check, // Add icon to "Oui" button
                          text: 'Oui',
                          onPressed: () async {
                            log("Name: $name");
                            log("Dossard: $dossard");
                            var tmp = await LoginController.login(name, dossard);
                            if (!tmp.hasError) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return const InfoScreen();
                                }),
                              );
                            } else {
                              showInSnackBar(context, tmp.error!);
                            }
                          },
                        ),
                        const SizedBox(height: 10), // Add space between buttons
                        DiscardButton(
                          icon: Icons.close, // Add icon to "Non" button
                          text: 'Non',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 20), // Add margin below the button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

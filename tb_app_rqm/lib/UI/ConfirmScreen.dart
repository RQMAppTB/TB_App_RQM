import 'dart:developer';

import 'package:flutter/material.dart';
import '../API/LoginController.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'InfoScreen.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 40.0), // Add margin
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
                              const Text(
                                "Est-ce bien toi ?",
                                style: TextStyle(fontSize: 20, color: Color(Config.COLOR_APP_BAR)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                textAlign: TextAlign.center, // Center the text
                                style: const TextStyle(
                                    fontSize: 24, color: Color(Config.COLOR_APP_BAR), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Spacer(), // Add spacer to push the buttons to the bottom
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
                            child: const Text(
                              'Oui',
                              style: TextStyle(color: Colors.white, fontSize: 20), // Increase font size
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Add space between buttons
                        Container(
                          width: double.infinity, // Full width
                          height: 50.0, // Set height to match the "Oui" button
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(Config.COLOR_APP_BAR), width: 2.0), // Outline with COLOR_APP_BAR
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, // Center transparent
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Non',
                              style: TextStyle(
                                  color: Color(Config.COLOR_APP_BAR), fontSize: 20), // Text color in COLOR_APP_BAR
                            ),
                          ),
                        ),
                        const SizedBox(height: 30), // Add margin below the button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0, // Center horizontally
            child: Center(
              child: Text(
                'v${Config.APP_VERSION}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

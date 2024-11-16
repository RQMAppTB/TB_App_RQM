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
              padding: const EdgeInsets.symmetric(horizontal: 50.0), // Add margin
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
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: const TextStyle(
                                    fontSize: 24, color: Color(Config.COLOR_APP_BAR), fontWeight: FontWeight.bold),
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
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Text(
              'v${Config.APP_VERSION}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: Column(
              children: [
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
                  decoration: BoxDecoration(
                    color: Color(Config.COLOR_APP_BAR).withOpacity(1), // 100% opacity
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Non',
                      style: TextStyle(color: Colors.white, fontSize: 20), // Increase font size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
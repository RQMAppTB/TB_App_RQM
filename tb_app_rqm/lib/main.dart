import 'package:flutter/material.dart';
import 'package:lrqm/Data/DossardData.dart';
import 'package:lrqm/UI/InfoScreen.dart';
import 'package:lrqm/UI/LoginScreen.dart';

import 'Data/NameData.dart';

void main() async {
  /// Ensure that the WidgetsBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Check if there are a name and a dossard number saved in the shared preferences
  final bool isLoggedIn = await NameData.doesNameExist() && await DossardData.doesDossardExist();

  /// Run the application
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RQM application',
      theme: ThemeData(
        fontFamily: 'Roboto', // Ensure the default font family is set to Poppins
      ),
      home: isLoggedIn ? const InfoScreen() : const Login(),
    );
  }
}

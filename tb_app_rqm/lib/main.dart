import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lrqm/Data/DossardData.dart';
import 'package:lrqm/UI/WorkingScreen.dart';
import 'package:lrqm/UI/LoginScreen.dart';

import 'Data/NameData.dart';

void main() async {
  /// Ensure that the WidgetsBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      title: 'La RQM APP',
      theme: ThemeData(
        fontFamily: 'Roboto', // Ensure the default font family is set to Poppins
      ),
      home: isLoggedIn ? const WorkingScreen() : const Login(),
    );
  }
}

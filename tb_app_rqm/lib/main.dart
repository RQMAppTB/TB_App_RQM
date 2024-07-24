
import 'package:flutter/material.dart';
import 'package:tb_app_rqm/Data/DossardData.dart';
import 'package:tb_app_rqm/UI/InfoScreen.dart';
import 'package:tb_app_rqm/UI/LoginScreen.dart';

import 'Data/NameData.dart';

void main() async {
  /// Ensure that the WidgetsBinding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  /// Check if there are a name and a dossard number saved in the shared preferences
  final bool _isLoggedIn = await NameData.doesNameExist() && await DossardData.doesDossardExist();

  /// Run the application
  runApp(MaterialApp(
    title: 'RQM application',
    home: _isLoggedIn ? const InfoScreen() : const Login(),
  ));
}
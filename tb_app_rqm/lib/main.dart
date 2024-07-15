
import 'package:flutter/material.dart';
import 'package:tb_app_rqm/Data/DossardData.dart';
import 'package:tb_app_rqm/UI/InfoScreen.dart';
import 'package:tb_app_rqm/UI/LoginScreen.dart';

import 'Data/NameData.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

/*
  */

  final bool _isLoggedIn = await NameData.doesNameExist() && await DossardData.doesDossardExist();

  runApp(MaterialApp(
    title: 'RQM application',
    home: _isLoggedIn ? const InfoScreen() : const Login(),
  ));
  //runApp(const MyApp());
}
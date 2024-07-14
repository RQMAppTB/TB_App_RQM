import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tb_app_rqm/Data/DossardData.dart';
import 'package:tb_app_rqm/UI/InfoScreen.dart';
import 'package:tb_app_rqm/UI/LoginScreen.dart';

import 'Data/NameData.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if(await Permission.location.request().isGranted &&
      await Permission.locationAlways.request().isGranted){
    log('Location permission granted');
  } else {
    log('Location permission not granted');
    exit(0);
  }

  final bool _isLoggedIn = await NameData.doesNameExist() && await DossardData.doesDossardExist();

  runApp(MaterialApp(
    title: 'RQM application',
    home: _isLoggedIn ? const InfoScreen() : const Login(),
  ));
  //runApp(const MyApp());
}
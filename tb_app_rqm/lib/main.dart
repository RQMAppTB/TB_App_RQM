import 'package:flutter/material.dart';
import 'package:tb_app_rqm/UI/InfoScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    title: 'RQM application',
    home: InfoScreen(),
  ));
  //runApp(const MyApp());
}
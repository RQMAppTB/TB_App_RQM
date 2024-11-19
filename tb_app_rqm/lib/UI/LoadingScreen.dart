import 'package:flutter/material.dart';
import '../Utils/config.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(Config.COLOR_BACKGROUND), // Set background color to light grey
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/pictures/LogoSimpleAnimated.gif',
                width: 60.0, // Set width to 50px
              ),
            ),
          ),
        ],
      ),
    );
  }
}

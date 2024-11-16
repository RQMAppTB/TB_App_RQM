import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Set background color to light grey
      body: Center(
        child: Image.asset('assets/pictures/LogoSimpleAnimated.gif'),
      ),
    );
  }
}

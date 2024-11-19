import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/LoginController.dart';
import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'ConfirmScreen.dart';
import 'LoadingScreen.dart'; // Import the LoadingScreen
import 'Components/ActionButton.dart'; // Import the ActionButton
import 'Components/HighlightPainter.dart'; // Import the HighlightPainter

/// Class to display the login screen.
/// This screen allows the user to enter his dossard number
/// and check if the name is correct.
/// The user can then access the information screen.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

/// State of the Login class.
class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  /// Controller to get the dossard number entered by the user.
  final TextEditingController _controller = TextEditingController();

  /// Name of the user.
  String _name = "";

  /// Dossard number of the user.
  int _dossard = -1;

  /// Boolean to check if the name is correct.
  bool _visibility = false;

  /// Boolean to check if the app is loading.
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    DistTotaleData.saveDistTotale(20);
    DistPersoData.saveDistPerso(10);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_controller.text.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  /// Function to show a snackbar with the message [value].
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text(value)));
  }

  /// Function to get the name of the user with the dossard number entered by the user.
  void _getUserame() async {
    log("Trying to login");

    // Hide the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingScreen()), // Ensure LoadingScreen is correctly referenced
    );

    try {
      int dossardNumber = int.parse(_controller.text);
      Result dosNumResult = await LoginController.getDossardName(dossardNumber);

      if (dosNumResult.error != null) {
        //show error message in snackbar
        showInSnackBar(dosNumResult.error!);
        setState(() {
          _visibility = false;
          _isLoading = false;
        });
        Navigator.pop(context); // Close the loading page
      } else {
        setState(() {
          _name = dosNumResult.value;
          _dossard = dossardNumber;
          _visibility = true;
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmScreen(name: _name, dossard: _dossard)),
        );
      }
    } catch (e) {
      showInSnackBar("Invalid dossard number");
      setState(() {
        _visibility = false;
        _isLoading = false;
      });
      Navigator.pop(context); // Close the loading page
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    _controller.addListener(_onTextChanged);
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: SizedBox(height: isKeyboardVisible ? 80 : 100),
                  ),
                  Visibility(
                    //visible: !isKeyboardVisible,
                    maintainSize: false,
                    child: Flexible(
                      flex: 3,
                      child: Center(
                        child: Image(image: AssetImage('assets/pictures/LogoTextAnimated.gif')),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: SizedBox(height: isKeyboardVisible ? 60 : 80),
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start, // Reduce margin
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                      children: [
                        const Text(
                          'Bienvenue,',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(Config.COLOR_APP_BAR), // Blue color
                            fontWeight: FontWeight.bold, // Bold
                          ),
                        ),
                        const SizedBox(height: 20), // Add small margin
                        Stack(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Entre ton ',
                                style: const TextStyle(fontSize: 16, color: Color(Config.COLOR_APP_BAR)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'numéro de dossard',
                                    style: TextStyle(
                                      fontSize: 16, // Remove font size difference
                                      color: Color(Config.COLOR_APP_BAR), // Blue color
                                      fontWeight: FontWeight.bold, // Bold
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' pour t\'identifier à l`évènement.',
                                    style: TextStyle(fontSize: 16, color: Color(Config.COLOR_APP_BAR)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20), // Add small margin
                        Container(
                          decoration: BoxDecoration(
                            color: Color(Config.COLOR_BUTTON).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
                            textAlign: TextAlign.center, // Center the text horizontally
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(8.0),
                            ),
                            style: TextStyle(
                              fontSize: 28,
                              color: Color(Config.COLOR_APP_BAR), // Set input text color to APP_COLOR
                              letterSpacing: 4.0, // Increase space between characters
                            ),
                          ),
                        ),
                        SizeTransition(
                          sizeFactor: _animation,
                          axis: Axis.horizontal,
                          axisAlignment: -1.0,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              '1 à 9999',
                              style: TextStyle(
                                color: Color(Config.COLOR_APP_BAR),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic, // Use italic style
                              ),
                            ),
                          ),
                        ),
                        Spacer(), // Add spacer to push the button and version text to the bottom
                        Container(
                          width: double.infinity, // Full width
                          child: ActionButton(
                            icon: Icons.login, // Add connection icon
                            text: 'Se connecter',
                            onPressed: _getUserame,
                          ),
                        ),
                        const SizedBox(height: 20), // Add margin below the button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 25,
            left: 25,
            child: Center(
              child: FutureBuilder<String>(
                future: Config.getAppVersion(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                      'v${snapshot.data}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

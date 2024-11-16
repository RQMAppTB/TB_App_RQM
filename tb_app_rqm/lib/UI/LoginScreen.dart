import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/LoginController.dart';
import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'InfoScreen.dart';
import 'ConfirmScreen.dart';
import 'LoadingPage.dart'; // Import the LoadingPage

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
class _LoginState extends State<Login> {
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

  @override
  void initState() {
    super.initState();
    DistTotaleData.saveDistTotale(20);
    DistPersoData.saveDistPerso(10);
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
      MaterialPageRoute(builder: (context) => const LoadingPage()), // Ensure LoadingPage is correctly referenced
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Set background color to light grey
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: SizedBox(height: isKeyboardVisible ? 100 : 100),
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
                        const SizedBox(height: 23), // Add small margin
                        RichText(
                          text: TextSpan(
                            text: 'Entre ton ',
                            style: const TextStyle(fontSize: 16, color: Color(Config.COLOR_APP_BAR)),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'numéro de dossard',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(Config.COLOR_APP_BAR), // Blue color
                                  fontWeight: FontWeight.bold, // Bold
                                ),
                              ),
                              const TextSpan(
                                text: ' pour te connecter.',
                                style: TextStyle(fontSize: 16, color: Color(Config.COLOR_APP_BAR)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20), // Add small margin
                        Container(
                          decoration: BoxDecoration(
                            color: Color(Config.COLOR_BUTTON).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              hintText: 'N° de dossard (1 à 9999)',
                              hintStyle: TextStyle(color: Color(Config.COLOR_BUTTON)), // Set placeholder color
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16.0),
                            ),
                          ),
                        ),
                        Spacer(), // Add spacer to push the button and version text to the bottom
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
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
                                  onPressed: _getUserame,
                                  child: const Text(
                                    'Se connecter',
                                    style: TextStyle(color: Colors.white, fontSize: 20), // Increase font size
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20), // Add margin below the button
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0), // Add margin
                                  child: Text(
                                    'v${Config.APP_VERSION}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
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
        ],
      ),
    );
  }
}

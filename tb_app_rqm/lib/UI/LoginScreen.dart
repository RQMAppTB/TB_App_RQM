import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/LoginController.dart';
import '../Data/DistPersoData.dart';
import '../Data/DistTotaleData.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'InfoScreen.dart';

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

    try {
      int dossardNumber = int.parse(_controller.text);
      Result dosNumResult = await LoginController.getDossardName(dossardNumber);

      if (dosNumResult.error != null) {
        //show error message in snackbar
        showInSnackBar(dosNumResult.error!);
        setState(() {
          _visibility = false;
        });
      } else {
        setState(() {
          _name = dosNumResult.value;
          _dossard = dossardNumber;
          _visibility = true;
        });
      }
    } catch (e) {
      showInSnackBar("Invalid dossard number");
      setState(() {
        _visibility = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          log("Trying to pop");
        },
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: const Color(Config.COLOR_APP_BAR),
              centerTitle: true,
              title: Text(style: const TextStyle(color: Color(Config.COLOR_TITRE)), 'Login v${Config.APP_VERSION}')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Expanded(
                  flex: 2,
                  child: Image(image: AssetImage('assets/pictures/LogoText.png')),
                ),
                Expanded(
                    flex: 8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            'Bienvenue'),
                        const Text(
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            'Veuillez entrer votre dossard'),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(hintText: 'XXXX'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(Config.COLOR_BUTTON)),
                          onPressed: _getUserame,
                          child: const Text('Login'),
                        ),

                        // Visibility widget to display the name of the user
                        // and ask if it is the correct name.
                        Visibility(
                          visible: _visibility,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              const Text(
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  "Est-ce le bon nom?"),
                              Text(
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                  _name),
                              const Padding(padding: EdgeInsets.all(20)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(Config.COLOR_BUTTON)),
                                    onPressed: () async {
                                      log("Name: $_name");
                                      log("Dossard: ${_controller.text}");
                                      var tmp =
                                          await LoginController.login(_name, _dossard); //int.parse(_controller.text));
                                      if (!tmp.hasError) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return const InfoScreen();
                                          }),
                                        );
                                      } else {
                                        showInSnackBar(tmp.error!);
                                      }
                                    },
                                    child: const Text('Oui'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(Config.COLOR_BUTTON)),
                                    onPressed: () {
                                      setState(() {
                                        _visibility = false;
                                      });
                                    },
                                    child: const Text('Non'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ));
  }
}

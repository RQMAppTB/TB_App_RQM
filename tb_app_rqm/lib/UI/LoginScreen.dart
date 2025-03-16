import 'dart:developer';
import 'dart:async'; // Import Timer from dart:async

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/NewEventController.dart';
import '../API/NewUserController.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'ConfirmScreen.dart';
import 'LoadingScreen.dart';
import 'Components/ActionButton.dart';
import '../Data/EventData.dart';
import 'Components/CountdownModal.dart';
import 'Components/TextModal.dart';

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

  /// Event status.
  bool _isEventActive = false;
  String _eventMessage = "";

  @override
  void initState() {
    super.initState();
    _checkEventStatus();
  }

  void _checkEventStatus() async {
    setState(() {
      _isEventActive = false; // Show loading screen while fetching event info
    });

    Result<List<dynamic>> eventsResult =
        await NewEventController.getAllEvents();
    if (eventsResult.hasError) {
      log("Error fetching events: ${eventsResult.error}"); // Log the error details
      setState(() {
        _isEventActive = true; // Render login page before showing modal
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTextModal(
          context,
          "Erreur",
          "Erreur lors de la récupération de l'évènement. Veuillez vérifier votre connexion internet.",
          showConfirmButton: true,
          onConfirm: _checkEventStatus, // Retry fetching events on confirmation
        );
      });
      return;
    }

    var events = eventsResult.value!;
    var event = events.firstWhere(
      (event) => event['name'] == Config.EVENT_NAME,
      orElse: () => null,
    );

    if (event == null) {
      setState(() {
        _isEventActive = true; // Render login page before showing modal
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTextModal(
          context,
          "Erreur",
          "L'évènement '${Config.EVENT_NAME}' n'existe pas.",
          showConfirmButton: true,
          onConfirm: _checkEventStatus, // Retry fetching events on confirmation
        );
      });
      return;
    }

    DateTime startDate = DateTime.parse(event['start_date']);
    DateTime endDate = DateTime.parse(event['end_date']);
    DateTime now = DateTime.now();

    // Save all event details using EventData
    await EventData.saveEvent(event);

    setState(() {
      _isEventActive = true; // Render login page
    });

    if (now.isBefore(startDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCountdownModal(context, "C'est bientôt l'heure !",
            startDate: startDate); // Show countdown modal
      });
    } else if (now.isAfter(endDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTextModal(context, "C'est fini !",
            "Malheureusement, l'évènement est terminé.");
      });
    }
  }

  void _onTextChanged() {}

  /// Function to show a snackbar with the message [value].
  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  /// Function to get the name of the user with the dossard number entered by the user.
  void _getUserame() async {
    log("Trying to login");

    // Hide the keyboard
    FocusScope.of(context).unfocus();

    setState(() {});

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoadingScreen()), // Ensure LoadingScreen is correctly referenced
    );

    try {
      int dossardNumber = int.parse(_controller.text);
      Result dosNumResult = await NewUserController.getUser(
          dossardNumber); // Use NewUserController

      if (dosNumResult.error != null) {
        // Show error message in snackbar
        showInSnackBar(dosNumResult.error!);
        setState(() {});
        Navigator.pop(context); // Close the loading page
      } else {
        setState(() {
          _name = dosNumResult
              .value['username']; // Extract username from the API response
          _dossard = dossardNumber;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ConfirmScreen(name: _name, dossard: _dossard)),
        );
      }
    } catch (e) {
      showInSnackBar("Numéro de dossard invalide ");
      setState(() {});
      Navigator.pop(context); // Close the loading page
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isEventActive) {
      return const LoadingScreen();
    }

    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    _controller.addListener(_onTextChanged);

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align text to the left
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: SizedBox(height: isKeyboardVisible ? 80 : 100),
                  ),
                  const Visibility(
                    //visible: !isKeyboardVisible,
                    maintainSize: false,
                    child: Flexible(
                      flex: 3,
                      child: Center(
                        child: Image(
                            image: AssetImage(
                                'assets/pictures/LogoTextAnimated.gif')),
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
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Reduce margin
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align text to the left
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
                              text: const TextSpan(
                                text: 'Entre ton ',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color(Config.COLOR_APP_BAR)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'numéro de dossard',
                                    style: TextStyle(
                                      fontSize:
                                          16, // Remove font size difference
                                      color: Color(
                                          Config.COLOR_APP_BAR), // Blue color
                                      fontWeight: FontWeight.bold, // Bold
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' pour t\'identifier à l`évènement.',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(Config.COLOR_APP_BAR)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20), // Add small margin
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(Config.COLOR_APP_BAR)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
                            textAlign: TextAlign
                                .center, // Center the text horizontally
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12.0),
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color(Config
                                  .COLOR_APP_BAR), // Set input text color to APP_COLOR
                              letterSpacing:
                                  8.0, // Increase space between characters
                              fontWeight: FontWeight.bold, //
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            '1 à 9999',
                            style: TextStyle(
                              color: Color(Config
                                  .COLOR_APP_BAR), // Reduce opacity to 0.5
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(), // Add spacer to push the button and version text to the bottom
                        SizedBox(
                          width: double.infinity, // Full width
                          child: ActionButton(
                            icon: Icons.login, // Add connection icon
                            text: 'Se connecter',
                            onPressed: _getUserame,
                          ),
                        ),
                        const SizedBox(
                            height: 12), // Add margin below the button
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

import 'dart:developer';
import 'dart:async'; // Import Timer from dart:async

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../API/NewEventController.dart'; // Import NewEventController
import '../API/NewUserController.dart';
import '../Utils/Result.dart';
import '../Utils/config.dart';
import 'ConfirmScreen.dart';
import 'LoadingScreen.dart'; 
import 'Components/ActionButton.dart'; 
import '../Data/EventData.dart'; // Ensure this import is present and correct

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
  Result<List<dynamic>> eventsResult = await NewEventController.getAllEvents();
  if (eventsResult.hasError) {
    _showBlockingModal("Erreur", "Erreur lors de la récupération des évènements.", startDate: DateTime.now());
    return;
  }

  var events = eventsResult.value!;
  var event = events.firstWhere(
    (event) => event['name'] == Config.EVENT_NAME,
    orElse: () => null,
  );

  if (event == null) {
    _showBlockingModal("Information", "L'évènement '${Config.EVENT_NAME}' n'existe pas.", startDate: DateTime.now());
    return;
  }

  DateTime startDate = DateTime.parse(event['start_date']);
  DateTime endDate = DateTime.parse(event['end_date']);
  DateTime now = DateTime.now();

  // Save all event details using EventData
  await EventData.saveEvent(event);

  String? eventName = await EventData.getEventName(); // Retrieve event name from EventData

  if (now.isBefore(startDate)) {
    _showBlockingModal("C'est bientôt l'heure !", "", startDate: startDate); // Message is now handled inside _showBlockingModal
  } else if (now.isAfter(endDate)) {
    _showBlockingModal("C'est fini !", "Malheureusement, l'évènement $eventName est terminé.", startDate: DateTime.now());
  } else {
    setState(() {
      _isEventActive = true;
    });
  }
}

void _showBlockingModal(String title, String message, {required DateTime startDate}) async {
  String? eventName = await EventData.getEventName(); // Retrieve event name from EventData
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            String calculateCountdown() {
              Duration difference = startDate.difference(DateTime.now());
              return "${difference.inDays} J : "
                  "${difference.inHours.remainder(24).toString().padLeft(2, '0')} H : "
                  "${difference.inMinutes.remainder(60).toString().padLeft(2, '0')} M : "
                  "${difference.inSeconds.remainder(60).toString().padLeft(2, '0')} S";
            }

            String countdown = calculateCountdown();

            Timer.periodic(const Duration(seconds: 1), (timer) {
              setState(() {
                countdown = calculateCountdown();
                if (DateTime.now().isAfter(startDate)) {
                  timer.cancel();
                  Navigator.of(context).pop(); // Close the dialog when the event starts
                }
              });
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              backgroundColor: Colors.white, // Default background color
              title: Text(
                title,
                style: const TextStyle(
                  color: Color(Config.COLOR_APP_BAR), // Use COLOR_APP_BAR for text
                  fontWeight: FontWeight.bold,
                  fontSize: 20, 
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: [
                  Text(
                    "Hey ! L'évènement \"$eventName\" n'a pas encore démarré.\n\n"
                    "Pas de stress, on compte les secondes ensemble jusqu'au top départ ! "
                    "Prépare-toi, hydrate-toi, et surtout, garde ton énergie pour le grand moment. 🚀",
                    style: const TextStyle(
                      color: Color(Config.COLOR_APP_BAR), // Use COLOR_APP_BAR for text
                      fontSize: 16, // Increase font size to 16
                    ),
                    textAlign: TextAlign.justify, 
                  ),
                  const SizedBox(height: 24), // Add spacing
                  Container(
                    width: double.infinity, // Take full width of the dialog
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(Config.COLOR_APP_BAR).withOpacity(0.2), // Use COLOR_APP_BAR with opacity 0.2
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      countdown,
                      style: const TextStyle(
                        fontSize: 20, // Larger font size for countdown
                        fontWeight: FontWeight.bold, // Bold text
                        color: Color(Config.COLOR_APP_BAR), // Use COLOR_APP_BAR for text
                      ),
                      textAlign: TextAlign.center, // Center align text
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  });
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
      MaterialPageRoute(builder: (context) => const LoadingScreen()), // Ensure LoadingScreen is correctly referenced
    );

    try {
      int dossardNumber = int.parse(_controller.text);
      Result dosNumResult = await NewUserController.getUser(dossardNumber); // Use NewUserController

      if (dosNumResult.error != null) {
        // Show error message in snackbar
        showInSnackBar(dosNumResult.error!);
        setState(() {});
        Navigator.pop(context); // Close the loading page
      } else {
        setState(() {
          _name = dosNumResult.value['username']; // Extract username from the API response
          _dossard = dossardNumber;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmScreen(name: _name, dossard: _dossard)),
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
    bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    _controller.addListener(_onTextChanged);

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add margin
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
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
                              text: const TextSpan(
                                text: 'Entre ton ',
                                style: TextStyle(fontSize: 16, color: Color(Config.COLOR_APP_BAR)),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'numéro de dossard',
                                    style: TextStyle(
                                      fontSize: 16, // Remove font size difference
                                      color: Color(Config.COLOR_APP_BAR), // Blue color
                                      fontWeight: FontWeight.bold, // Bold
                                    ),
                                  ),
                                  TextSpan(
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
                            color: const Color(Config.COLOR_APP_BAR).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                            ],
                            textAlign: TextAlign.center, // Center the text horizontally
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(8.0),
                            ),
                            style: const TextStyle(
                              fontSize: 28,
                              color: Color(Config.COLOR_APP_BAR), // Set input text color to APP_COLOR
                              letterSpacing: 8.0, // Increase space between characters
                              fontWeight: FontWeight.bold, //
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Text(
                            '1 à 9999',
                            style: TextStyle(
                              color: Color(Config.COLOR_APP_BAR), // Reduce opacity to 0.5
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

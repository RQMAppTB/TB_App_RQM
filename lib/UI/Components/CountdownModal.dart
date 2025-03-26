import 'dart:async';
import 'package:flutter/material.dart';
import '../../Data/EventData.dart';
import '../../Utils/config.dart';

void showCountdownModal(BuildContext context, String title, {required DateTime startDate}) async {
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
                    textAlign: TextAlign.justify, // Justify text alignment
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

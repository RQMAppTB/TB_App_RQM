import 'package:flutter/material.dart';
import '../../Utils/config.dart';
import 'ActionButton.dart';

void showTextModal(BuildContext context, String title, String message,
    {bool showConfirmButton = false, VoidCallback? onConfirm}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
            children: [
              Text(
                message,
                style: const TextStyle(
                  color:
                      Color(Config.COLOR_APP_BAR), // Use COLOR_APP_BAR for text
                  fontSize: 16, // Increase font size to 16
                ),
                textAlign: TextAlign.left, // Justify text alignment
              ),
              if (showConfirmButton) ...[
                const SizedBox(height: 20), // Add spacing before the button
                ActionButton(
                  text: "OK",
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the modal
                    if (onConfirm != null) {
                      onConfirm(); // Execute the onConfirm callback
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  });
}

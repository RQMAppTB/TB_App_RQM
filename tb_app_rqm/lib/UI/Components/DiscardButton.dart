import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class DiscardButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const DiscardButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width
      height: 50.0, // Set height to match the "Oui" button
      decoration: BoxDecoration(
        border: Border.all(color: Color(Config.COLOR_APP_BAR), width: 2.0), // Outline with COLOR_APP_BAR
        borderRadius: BorderRadius.circular(32.0), // Same radius as ActionButton
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Center transparent
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Color(Config.COLOR_APP_BAR), size: 28),
            if (icon != null) SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(color: Color(Config.COLOR_APP_BAR), fontSize: 20), // Text color in COLOR_APP_BAR
            ),
          ],
        ),
      ),
    );
  }
}

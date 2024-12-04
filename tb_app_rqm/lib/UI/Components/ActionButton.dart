import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    this.icon = Icons.check, // Default icon set to check
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width
      decoration: BoxDecoration(
        color: const Color(Config.COLOR_BUTTON),
        borderRadius: BorderRadius.circular(32.0), // Same radius as InfoCard
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Same radius as InfoCard
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: const Color(Config.COLOR_BACKGROUND), size: 28),
            if (icon != null) const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Color(Config.COLOR_BACKGROUND),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

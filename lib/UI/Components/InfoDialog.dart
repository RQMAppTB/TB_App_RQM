import 'package:flutter/material.dart';
import '../../Utils/config.dart';
import 'ActionButton.dart';
import 'DiscardButton.dart';

class InfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onYes;
  final VoidCallback onNo;
  final Widget? logo; // Add optional logo

  const InfoDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onYes,
    required this.onNo,
    this.logo, // Initialize optional logo
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center, // Align to the bottom
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9, // Increase width
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 16, // Increase blur radius
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: [
                  Row(
                    children: [
                      if (logo != null) // Check if logo is not null
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: logo!,
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(Config.COLOR_APP_BAR),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(Config.COLOR_APP_BAR),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      ActionButton(
                        icon: Icons.check,
                        text: 'OUI',
                        onPressed: onYes,
                      ),
                      const SizedBox(height: 8),
                      DiscardButton(
                        icon: Icons.close,
                        text: 'NON',
                        onPressed: onNo,
                      ),
                    ],
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

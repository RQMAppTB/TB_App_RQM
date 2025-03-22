import 'package:flutter/material.dart';
import '../../Utils/config.dart';

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
            alignment: Alignment.bottomCenter, // Align to the bottom
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onNo,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(Config.COLOR_APP_BAR),
                          side: BorderSide(color: const Color(Config.COLOR_APP_BAR)),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('NON'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onYes,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(Config.COLOR_BUTTON),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('OUI'),
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

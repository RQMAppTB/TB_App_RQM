import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class DialogComponent {
  static void showIconMenu(BuildContext context, Function(IconData) onIconSelected) {
    final List<IconData> icons = [
      Icons.face,
      Icons.face_2,
      Icons.face_3,
      Icons.face_4,
      Icons.face_5,
      Icons.face_6,
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black54, // Grey out the rest of the screen
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8, // Make it 80% of the screen width
                decoration: BoxDecoration(
                  color: Colors.white, // Match the background color of the InfoCard
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Add padding around the content
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Choisis ton avatar !',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(Config.COLOR_APP_BAR),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: icons.map((icon) {
                          return GestureDetector(
                            onTap: () {
                              onIconSelected(icon);
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(icon, size: 40, color: const Color(Config.COLOR_APP_BAR)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

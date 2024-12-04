import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Correct import
import '../../API/LoginController.dart';
import '../../Utils/config.dart';
import '../LoginScreen.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showInfoButton;

  const TopAppBar({super.key, required this.title, this.showInfoButton = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.white, // Set background color to white
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Image.asset('assets/pictures/LogoText.png', height: 28),
                ),
                const Spacer(),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.public, size: 24, color: Color(Config.COLOR_APP_BAR)),
                    onPressed: () async {
                      final Uri url = Uri.parse('https://larouequimarche.ch/');
                      await launch(
                        url.toString(),
                        forceSafariVC: false,
                        forceWebView: false,
                        headers: <String, String>{'my_header_key': 'my_header_value'},
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outlined, size: 24, color: Color(Config.COLOR_APP_BAR)),
                    onPressed: () {
                      // Add your info button action here
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 24, color: Color(Config.COLOR_APP_BAR)),
                    onPressed: () {
                      LoginController.logout().then((result) {
                        if (result.hasError) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text("Please try again later")));
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          color: Color(Config.COLOR_APP_BAR).withOpacity(0.1),
          height: 4.0,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}

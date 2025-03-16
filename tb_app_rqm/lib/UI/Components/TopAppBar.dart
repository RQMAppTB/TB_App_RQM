import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/config.dart';
import '../../Utils/LogHelper.dart';
import '../LoginScreen.dart';
import '../InfoScreen.dart';
import '../../Data/DataUtils.dart';
import '../../Data/MeasureData.dart';
import '../../API/NewMeasureController.dart';

class TopAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showInfoButton;

  const TopAppBar({super.key, required this.title, this.showInfoButton = true});

  @override
  _TopAppBarState createState() => _TopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}

class _TopAppBarState extends State<TopAppBar> {
  int _infoButtonClickCount = 0;
  bool _showShareButton = false;

  void _incrementInfoButtonClickCount() {
    setState(() {
      _infoButtonClickCount++;
      if (_infoButtonClickCount >= 5) {
        _showShareButton = true;
      }
    });
  }

  void _resetInfoButtonClickCount() {
    setState(() {
      _infoButtonClickCount = 0;
      _showShareButton = false;
    });
  }

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
                  child: GestureDetector(
                    onTap:
                        _incrementInfoButtonClickCount, // Increment count on logo tap
                    child:
                        Image.asset('assets/pictures/LogoText.png', height: 28),
                  ),
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
                  if (_showShareButton)
                    IconButton(
                      icon: const Icon(Icons.share,
                          size: 24,
                          color:
                              Color(Config.COLOR_APP_BAR)), // Add share button
                      onPressed: () async {
                        await LogHelper.shareLogFile(); // Leverage shareLog
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.public,
                        size: 24, color: Color(Config.COLOR_APP_BAR)),
                    onPressed: () async {
                      final Uri url = Uri.parse('https://larouequimarche.ch/');
                      await launch(
                        url.toString(),
                        forceSafariVC: false,
                        forceWebView: false,
                        headers: <String, String>{
                          'my_header_key': 'my_header_value'
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outlined,
                        size: 24, color: Color(Config.COLOR_APP_BAR)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InfoScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout,
                        size: 24, color: Color(Config.COLOR_APP_BAR)),
                    onPressed: () async {
                      if (await MeasureData.isMeasureOngoing()) {
                        String? measureId = await MeasureData.getMeasureId();
                        final stopResult =
                            await NewMeasureController.stopMeasure();
                        if (stopResult.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Failed to stop measure (ID: $measureId): ${stopResult.error}")),
                          );
                          return;
                        }
                      }

                      final cleared = await DataUtils.deleteAllData();
                      if (cleared) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Failed to clear user data")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          color: const Color(Config.COLOR_APP_BAR).withOpacity(0.1),
          height: 3.0,
        ),
      ],
    );
  }
}

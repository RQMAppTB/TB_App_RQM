import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../Utils/config.dart';
import 'HighlightPainter.dart';

class ProgressCard extends StatefulWidget {
  final String title;
  final String value;
  final double percentage;
  final Widget logo;

  ProgressCard({required this.title, required this.value, required this.percentage, required this.logo});

  @override
  _ProgressCardState createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        size: 32,
                        color: Color(Config.COLOR_APP_BAR),
                      ),
                      child: widget.logo,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(Config.COLOR_APP_BAR),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: HighlightPainter(),
                            ),
                          ),
                          Text(
                            widget.value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(Config.COLOR_APP_BAR),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: widget.percentage / 100,
              backgroundColor: Color(Config.COLOR_APP_BAR).withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Color(Config.COLOR_APP_BAR)),
              minHeight: 4,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${widget.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(Config.COLOR_APP_BAR)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

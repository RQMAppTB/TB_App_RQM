import 'package:flutter/material.dart';
import 'dart:math';
import '../../Utils/config.dart';

class InfoCard extends StatefulWidget {
  final Widget logo;
  final String title;
  final String data;
  final String? additionalDetails;
  final double? progressValue;

  InfoCard({
    required this.logo,
    required this.title,
    required this.data,
    this.additionalDetails,
    this.progressValue,
  });

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    if (widget.additionalDetails != null || widget.progressValue != null) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(Config.COLOR_BACKGROUND)],
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconTheme(
                    data: IconThemeData(
                      size: 32,
                      color: Color(Config.COLOR_APP_BAR),
                    ),
                    child: widget.logo,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(Config.COLOR_APP_BAR),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.data,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(Config.COLOR_APP_BAR),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.additionalDetails != null || widget.progressValue != null)
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Color(Config.COLOR_APP_BAR),
                    ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                if (widget.additionalDetails != null)
                  Text(
                    widget.additionalDetails!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(Config.COLOR_APP_BAR),
                    ),
                  ),
                if (widget.additionalDetails != null) const SizedBox(height: 16),
                if (widget.progressValue != null)
                  LinearProgressIndicator(
                    value: widget.progressValue,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(Config.COLOR_APP_BAR)),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

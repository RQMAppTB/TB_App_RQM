import 'package:flutter/material.dart';
import 'dart:math';
import '../../Utils/config.dart';

class InfoCard extends StatefulWidget {
  final Widget logo;
  final String title;
  final String data;
  final String? additionalDetails;
  final List<ActionItem>? actionItems; // Combine action icons and labels

  InfoCard({
    required this.logo,
    required this.title,
    required this.data,
    this.additionalDetails,
    this.actionItems, // Initialize action items
  });

  @override
  _InfoCardState createState() => _InfoCardState();
}

class ActionItem {
  final Icon icon;
  final String label;
  final VoidCallback onPressed;

  ActionItem({required this.icon, required this.label, required this.onPressed});
}

class _InfoCardState extends State<InfoCard> {
  bool _isExpanded = false;

  bool get _canExpand => widget.additionalDetails != null;

  void _toggleExpanded() {
    if (_canExpand) {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white, // Set the background color to white
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
        padding: const EdgeInsets.all(16.0), // Move padding here
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
                if (_canExpand)
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
            ],
            if (widget.actionItems != null && widget.actionItems!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actionItems!.map((actionItem) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0), // Add left margin between icons
                    child: Column(
                      children: [
                        IconButton(
                          icon: actionItem.icon,
                          onPressed: actionItem.onPressed,
                        ),
                        Text(
                          actionItem.label,
                          style: TextStyle(color: Color(Config.COLOR_APP_BAR)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

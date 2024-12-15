import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class InfoCard extends StatefulWidget {
  final Widget? logo; // Make logo optional
  final String title;
  final String data;
  final String? additionalDetails;
  final List<ActionItem>? actionItems; // Combine action icons and labels

  const InfoCard({
    super.key,
    this.logo, // Make logo optional
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

class _InfoCardState extends State<InfoCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canExpand => widget.additionalDetails != null;

  void _toggleExpanded() {
    if (_canExpand) {
      setState(() {
        _isExpanded = !_isExpanded;
        if (_isExpanded) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
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
          color: Colors.white, // Changed from gradient to white color
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0), // Move padding here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.logo != null) // Check if logo is not null
                  IconTheme(
                    data: const IconThemeData(
                      size: 32,
                      color: Color(Config.COLOR_APP_BAR),
                    ),
                    child: widget.logo!,
                  ),
                if (widget.logo != null) const SizedBox(width: 16), // Add spacing if logo is present
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
                    color: const Color(Config.COLOR_APP_BAR),
                  ),
              ],
            ),
            SizeTransition(
              sizeFactor: _animation,
              axisAlignment: -1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add padding before additionalDetails text
                  if (widget.additionalDetails != null) const SizedBox(height: 16),
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
              ),
            ),
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
                          style: const TextStyle(color: Color(Config.COLOR_APP_BAR)),
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

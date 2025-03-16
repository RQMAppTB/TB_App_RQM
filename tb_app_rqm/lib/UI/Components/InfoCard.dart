import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class InfoCard extends StatefulWidget {
  final Widget? logo;
  final String title;
  final String data;
  final String? additionalDetails;
  final List<ActionItem>? actionItems;

  const InfoCard({
    super.key,
    this.logo,
    required this.title,
    required this.data,
    this.additionalDetails,
    this.actionItems,
  });

  @override
  _InfoCardState createState() => _InfoCardState();
}

class ActionItem {
  final Icon icon;
  final String label;
  final VoidCallback onPressed;

  ActionItem(
      {required this.icon, required this.label, required this.onPressed});
}

class _InfoCardState extends State<InfoCard>
    with SingleTickerProviderStateMixin {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border(
            left: BorderSide(
              color: Color(Config.COLOR_BUTTON), // Add right border
              width: 2.0, // Set the width of the right border
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow color
              blurRadius: 4.0, // Reduced blur radius for subtle shadow
              offset: Offset(0, 2), // Vertical shadow offset
            ),
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.05), // Even lighter shadow color
              blurRadius: 2.0, // Smaller blur radius
              offset: Offset(2, 0), // Horizontal shadow offset
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.logo != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(Config.COLOR_BACKGROUND).withOpacity(1),
                    ),
                    child: Center(
                      child: IconTheme(
                        data: const IconThemeData(
                          size: 28,
                          color: Color(Config.COLOR_APP_BAR),
                        ),
                        child: widget.logo!,
                      ),
                    ),
                  ),
                if (widget.logo != null) const SizedBox(width: 12),
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
                      const SizedBox(height: 4),
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
                  if (widget.additionalDetails != null)
                    const SizedBox(height: 16),
                  if (widget.additionalDetails != null)
                    Text(
                      widget.additionalDetails!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(Config.COLOR_APP_BAR),
                      ),
                    ),
                  if (widget.additionalDetails != null)
                    const SizedBox(height: 16),
                ],
              ),
            ),
            if (widget.actionItems != null &&
                widget.actionItems!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actionItems!.map((actionItem) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      children: [
                        IconButton(
                          icon: actionItem.icon,
                          onPressed: actionItem.onPressed,
                        ),
                        Text(
                          actionItem.label,
                          style: const TextStyle(
                              color: Color(Config.COLOR_APP_BAR)),
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

import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class ProgressCard extends StatefulWidget {
  final String title;
  final String value;
  final double percentage;
  final Widget logo;

  const ProgressCard(
      {super.key, required this.title, required this.value, required this.percentage, required this.logo});

  @override
  _ProgressCardState createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = true; // Set to true by default
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
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconTheme(
                    data: const IconThemeData(
                      size: 32,
                      color: Color(Config.COLOR_APP_BAR),
                    ),
                    child: widget.logo,
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
                  ),
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
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 1, // 33% of the row
                          child: Text(
                            '${widget.percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(Config.COLOR_APP_BAR),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3, // 66% of the row
                          child: LinearProgressIndicator(
                            value: widget.percentage / 100,
                            backgroundColor: const Color(Config.COLOR_APP_BAR).withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(Config.COLOR_APP_BAR)),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

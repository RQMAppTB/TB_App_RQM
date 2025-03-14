import 'package:flutter/material.dart';
import '../../Utils/config.dart';

class HighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(Config.COLOR_BUTTON).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.3, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.75, size.height * 1.0, size.width * 0.5, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.8, 0, size.height * 0.9)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

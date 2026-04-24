import 'package:flutter/material.dart';
import 'dart:math';

class StopIcon extends StatelessWidget {
  final Color backgroundColor;
  final Color crossColor;

  const StopIcon({
    super.key,
    required this.backgroundColor,
    required this.crossColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _RedCrossPainter(
          backgroundColor: backgroundColor,
          crossColor: crossColor,
        ),
      ),
    );
  }
}

class _RedCrossPainter extends CustomPainter {
  final Color backgroundColor;
  final Color crossColor;

  _RedCrossPainter({
    required this.backgroundColor,
    required this.crossColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // Draw the background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the cross (within a slightly smaller circle to avoid edge bleed)
    final crossPaint = Paint()
      ..color = crossColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Padding from edge
    final padding = 6.0;
    final p1 = Offset(padding, padding);
    final p2 = Offset(size.width - padding, size.height - padding);
    final p3 = Offset(padding, size.height - padding);
    final p4 = Offset(size.width - padding, padding);

    canvas.drawLine(p1, p2, crossPaint);
    canvas.drawLine(p3, p4, crossPaint);
  }

  @override
  bool shouldRepaint(covariant _RedCrossPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.crossColor != crossColor;
  }
}

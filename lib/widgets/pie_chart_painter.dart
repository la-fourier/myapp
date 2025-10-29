import 'dart:math';

import 'package:flutter/material.dart';

class PieChartPainter extends CustomPainter {
  final List<Color> colors;

  PieChartPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) {
      return;
    }

    final paint = Paint()..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -pi / 2;
    final sweepAngle = 2 * pi / colors.length;

    for (final color in colors) {
      paint.color = color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

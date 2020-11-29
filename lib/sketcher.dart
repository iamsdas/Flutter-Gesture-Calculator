import 'package:flutter/material.dart';

class Sketcher extends CustomPainter {
  final List<Offset> points;

  Sketcher(this.points);
  @override
  bool shouldRepaint(Sketcher old) {
    return old.points != points;
  }

  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20.0;

    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }
}

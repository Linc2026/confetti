import 'package:flutter/material.dart';
import 'confetti_doodle_logic.dart';
class DoodlePainter extends CustomPainter {
  final List<DoodleStroke> strokes;
  final DoodleStroke? currentStroke;
  DoodlePainter({required this.strokes, this.currentStroke});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
    canvas.restore();
  }
  void _drawStroke(Canvas canvas, DoodleStroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = Paint()
      ..color = stroke.isEraser ? Colors.transparent : stroke.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver;
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      canvas.drawCircle(
        p.offset,
        p.width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }
    for (var i = 1; i < stroke.points.length; i++) {
      final a = stroke.points[i - 1];
      final b = stroke.points[i];
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = b.width;
      canvas.drawLine(a.offset, b.offset, paint);
    }
  }
  @override
  bool shouldRepaint(DoodlePainter old) =>
      old.strokes != strokes || old.currentStroke != currentStroke;
}

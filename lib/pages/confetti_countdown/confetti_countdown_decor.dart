import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
class CountdownFuseRingPainter extends CustomPainter {
  final double progress;
  final bool urgent;
  final bool started;
  const CountdownFuseRingPainter({
    required this.progress,
    required this.urgent,
    required this.started,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 9;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = const Color(0xFFFFF8F2).withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    if (sweep <= 0) return;
    final color = !started
        ? const Color(0xFFFFF8F2).withOpacity(0.42)
        : (urgent ? AppColors.warning : AppColors.primary);
    if (started) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = color.withOpacity(0.38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );
  }
  @override
  bool shouldRepaint(covariant CountdownFuseRingPainter old) =>
      old.progress != progress || old.urgent != urgent || old.started != started;
}
class CountdownPulsingText extends StatefulWidget {
  final String text;
  final bool isUrgent;
  final TextStyle style;
  const CountdownPulsingText({
    super.key,
    required this.text,
    required this.isUrgent,
    required this.style,
  });
  @override
  State<CountdownPulsingText> createState() => _CountdownPulsingTextState();
}
class _CountdownPulsingTextState extends State<CountdownPulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final text = Text(
      widget.text,
      style: widget.style,
      textAlign: TextAlign.center,
    );
    if (!widget.isUrgent) return text;
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: text,
      ),
    );
  }
}

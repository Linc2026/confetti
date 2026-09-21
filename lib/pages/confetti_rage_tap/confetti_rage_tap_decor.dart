import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/app_colors.dart';
import 'confetti_rage_tap_logic.dart';
class RageTapHeatTicks extends StatelessWidget {
  final int heatLevel;
  const RageTapHeatTicks({super.key, required this.heatLevel});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final on = heatLevel >= i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: i == heatLevel && heatLevel > 0 ? 16.w : 10.w,
          height: 3.h,
          margin: EdgeInsets.only(right: 4.w),
          decoration: BoxDecoration(
            color: on
                ? AppColors.primary.withOpacity(0.35 + i * 0.22)
                : AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }),
    );
  }
}
class RageTapFxCanvas extends StatefulWidget {
  final List<RippleData> ripples;
  final List<Offset> dots;
  final List<CrackImpact> cracks;
  const RageTapFxCanvas({
    super.key,
    required this.ripples,
    required this.dots,
    required this.cracks,
  });
  @override
  State<RageTapFxCanvas> createState() => _RageTapFxCanvasState();
}
class _RageTapFxCanvasState extends State<RageTapFxCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tick;
  @override
  void initState() {
    super.initState();
    _tick = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }
  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _tick,
        builder: (_, __) => CustomPaint(
          painter: _RageFxPainter(
            ripples: widget.ripples,
            dots: widget.dots,
            cracks: widget.cracks,
            nowMs: DateTime.now().millisecondsSinceEpoch,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
class _RageFxPainter extends CustomPainter {
  final List<RippleData> ripples;
  final List<Offset> dots;
  final List<CrackImpact> cracks;
  final int nowMs;
  const _RageFxPainter({
    required this.ripples,
    required this.dots,
    required this.cracks,
    required this.nowMs,
  });
  @override
  void paint(Canvas canvas, Size size) {
    for (final crack in cracks) {
      _paintCrack(canvas, crack);
    }
    final n = dots.length;
    for (var i = 0; i < n; i++) {
      final u = (i + 1) / n;
      canvas.drawCircle(
        dots[i],
        8 + u * 7,
        Paint()
          ..color = AppColors.primary.withOpacity(0.07 + u * 0.16)
          ..style = PaintingStyle.fill,
      );
    }
    for (final r in ripples) {
      final t = ((nowMs - r.startMs) / kRageRippleMs).clamp(0.0, 1.0);
      if (t >= 1) continue;
      final fade = 1 - t;
      final radius = 12 + t * 78;
      canvas.drawCircle(
        r.position,
        radius,
        Paint()
          ..color = AppColors.primary.withOpacity(0.55 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2 * fade,
      );
      if (t < 0.35) {
        canvas.drawCircle(
          r.position,
          6 + t * 22,
          Paint()
            ..color = AppColors.primary.withOpacity(0.42 * (1 - t / 0.35))
            ..style = PaintingStyle.fill,
        );
      }
      if (t > 0.12) {
        final t2 = ((t - 0.12) / 0.88).clamp(0.0, 1.0);
        canvas.drawCircle(
          r.position,
          8 + t2 * 96,
          Paint()
            ..color = AppColors.primary.withOpacity(0.28 * (1 - t2))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6 * (1 - t2),
        );
      }
    }
  }
  void _paintCrack(Canvas canvas, CrackImpact crack) {
    final grow = Curves.easeOut.transform(
      ((nowMs - crack.startMs) / 220).clamp(0.0, 1.0),
    );
    if (grow <= 0) return;
    final rng = Random(crack.seed);
    final rays = 6 + rng.nextInt(3);
    final core = Paint()
      ..color = const Color(0xFFF7F0E8).withOpacity(0.55 + grow * 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final edge = Paint()
      ..color = const Color(0xFF1C1917).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < rays; i++) {
      final angle = (i / rays) * pi * 2 + (rng.nextDouble() - 0.5) * 0.5;
      final len = (26 + rng.nextDouble() * 48) * grow;
      final path = Path()..moveTo(crack.position.dx, crack.position.dy);
      var x = crack.position.dx;
      var y = crack.position.dy;
      final segs = 3 + rng.nextInt(2);
      for (var s = 1; s <= segs; s++) {
        final t = s / segs;
        x = crack.position.dx +
            cos(angle) * len * t +
            (rng.nextDouble() - 0.5) * 10;
        y = crack.position.dy +
            sin(angle) * len * t +
            (rng.nextDouble() - 0.5) * 10;
        path.lineTo(x, y);
        if (s == 2 && rng.nextBool()) {
          final branch = Path()
            ..moveTo(x, y)
            ..lineTo(
              x + cos(angle + 0.8) * len * 0.35,
              y + sin(angle + 0.8) * len * 0.35,
            );
          canvas.drawPath(branch, edge);
          canvas.drawPath(branch, core);
        }
      }
      canvas.drawPath(path, edge);
      canvas.drawPath(path, core);
    }
  }
  @override
  bool shouldRepaint(covariant _RageFxPainter old) =>
      old.nowMs != nowMs ||
      old.ripples != ripples ||
      old.dots != dots ||
      old.cracks != cracks;
}

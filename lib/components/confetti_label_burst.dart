import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/confetti_fonts.dart';
import '../utils/app_colors.dart';
import 'confetti_shred_fx.dart';
class ConfettiLabelBurst extends StatefulWidget {
  final String label;
  const ConfettiLabelBurst({super.key, required this.label});
  @override
  State<ConfettiLabelBurst> createState() => _ConfettiLabelBurstState();
}
class _Bit {
  final String? glyph;
  final double angle;
  final double speed;
  final double spin;
  final double delay;
  final double size;
  final Color color;
  final int seed;
  const _Bit({
    this.glyph,
    required this.angle,
    required this.speed,
    required this.spin,
    required this.delay,
    required this.size,
    required this.color,
    required this.seed,
  });
}
class _ConfettiLabelBurstState extends State<ConfettiLabelBurst>
    with SingleTickerProviderStateMixin {
  static const _palette = [
    Color(0xFFE85A42),
    Color(0xFFF3A394),
    Color(0xFFF7F0E8),
    Color(0xFFE8C07A),
  ];
  late final AnimationController _ctrl;
  late final List<_Bit> _bits;
  @override
  void initState() {
    super.initState();
    final rng = Random(widget.label.hashCode);
    final glyphs = widget.label.split('');
    _bits = [
      for (var i = 0; i < glyphs.length; i++)
        _Bit(
          glyph: glyphs[i],
          angle: -0.7 + i * 0.7 + (rng.nextDouble() - 0.5) * 0.3,
          speed: 0.22 + rng.nextDouble() * 0.28,
          spin: (rng.nextDouble() - 0.5) * 2.8,
          delay: 0,
          size: 56 + rng.nextDouble() * 12,
          color: AppColors.primary,
          seed: rng.nextInt(9999),
        ),
      for (var i = 0; i < 28; i++)
        _Bit(
          angle: rng.nextDouble() * pi * 2,
          speed: 0.16 + rng.nextDouble() * 0.5,
          spin: (rng.nextDouble() - 0.5) * 6,
          delay: rng.nextDouble() * 0.08,
          size: 7 + rng.nextDouble() * 16,
          color: _palette[rng.nextInt(_palette.length)],
          seed: rng.nextInt(9999),
        ),
    ];
    _ctrl = AnimationController(vsync: this, duration: kShredFxDuration)
      ..forward();
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value;
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest;
              final origin = Offset(size.width * 0.5, size.height * 0.44);
              final charge = Curves.easeOutBack.transform((t / 0.22).clamp(0.0, 1.0));
              final hold = t < 0.3;
              final glow = t < 0.32
                  ? 0.35 + charge * 0.45
                  : (1 - ((t - 0.32) / 0.35).clamp(0.0, 1.0)) * 0.5;
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    size: size,
                    painter: _EnergyPainter(
                      bits: _bits,
                      origin: origin,
                      t: t,
                      glow: glow,
                    ),
                  ),
                  if (hold)
                    Center(
                      child: Transform.translate(
                        offset: Offset(0, -size.height * 0.06),
                        child: Opacity(
                          opacity: t < 0.06 ? t / 0.06 : 1,
                          child: Transform.scale(
                            scale: 0.72 + charge * 0.34,
                            child: Text(
                              widget.label,
                              style: ConfettiFonts.fraunces(
                                fontSize: 88.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: -2.5,
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primary.withOpacity(0.7),
                                    blurRadius: 28,
                                  ),
                                  Shadow(
                                    color: const Color(0xFFF7F0E8).withOpacity(0.35),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
class _EnergyPainter extends CustomPainter {
  final List<_Bit> bits;
  final Offset origin;
  final double t;
  final double glow;
  const _EnergyPainter({
    required this.bits,
    required this.origin,
    required this.t,
    required this.glow,
  });
  @override
  void paint(Canvas canvas, Size size) {
    if (glow > 0) {
      canvas.drawCircle(
        origin,
        size.shortestSide * (0.18 + t * 0.12),
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.primary.withOpacity(0.55 * glow),
              AppColors.primary.withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(center: origin, radius: size.shortestSide * 0.4)),
      );
    }
    if (t > 0.08) {
      final ringT = ((t - 0.18) / 0.55).clamp(0.0, 1.0);
      if (ringT > 0) {
        canvas.drawCircle(
          origin,
          40 + ringT * size.shortestSide * 0.72,
          Paint()
            ..color = const Color(0xFFF7F0E8).withOpacity(0.28 * (1 - ringT))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 * (1 - ringT),
        );
      }
    }
    if (t < 0.3) {
      final crackT = ((t - 0.14) / 0.16).clamp(0.0, 1.0);
      if (crackT > 0) _paintFaceCracks(canvas, crackT);
      return;
    }
    for (final b in bits) {
      final local = ((t - 0.28 - b.delay) / 0.72).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final fly = Curves.easeOutCubic.transform(local);
      final fall = local * local * size.height * 0.42;
      final pos = origin +
          Offset(cos(b.angle), sin(b.angle)) * (b.speed * size.shortestSide * fly) +
          Offset(0, fall);
      final fade = (1 - Curves.easeIn.transform(local)).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(b.spin * fly);
      if (b.glyph != null) {
        final tp = TextPainter(
          text: TextSpan(
            text: b.glyph,
            style: ConfettiFonts.fraunces(
              fontSize: b.size,
              fontWeight: FontWeight.w700,
              color: b.color.withOpacity(fade),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      } else {
        final paint = Paint()
          ..color = b.color.withOpacity(fade * 0.92)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
        canvas.drawPath(_scrap(b.size, b.seed), paint);
      }
      canvas.restore();
    }
  }
  void _paintFaceCracks(Canvas canvas, double crackT) {
    final rng = Random(11);
    final paint = Paint()
      ..color = const Color(0xFFF7F0E8).withOpacity(0.75 * crackT)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final a = (i / 7) * pi * 2 + rng.nextDouble() * 0.3;
      final len = (18 + rng.nextDouble() * 36) * crackT;
      final path = Path()..moveTo(origin.dx, origin.dy);
      path.lineTo(
        origin.dx + cos(a) * len + (rng.nextDouble() - 0.5) * 8,
        origin.dy + sin(a) * len + (rng.nextDouble() - 0.5) * 8,
      );
      canvas.drawPath(path, paint);
    }
  }
  Path _scrap(double s, int seed) {
    final rng = Random(seed);
    final path = Path();
    const n = 6;
    for (var i = 0; i < n; i++) {
      final a = (i / n) * pi * 2 + rng.nextDouble() * 0.35;
      final r = s * (0.4 + rng.nextDouble() * 0.7);
      final p = Offset(cos(a) * r, sin(a) * r * 0.72);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }
  @override
  bool shouldRepaint(covariant _EnergyPainter old) => old.t != t;
}

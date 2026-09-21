import 'dart:math';
import 'package:flutter/material.dart';
import '../db_confetti/db_confetti_entity.dart';
import '../models/pen_theme.dart';
const Duration kShredFxDuration = Duration(milliseconds: 2000);
enum ShredFxStyle { crispy, autumn, dissolve, bird, frost, snow }
ShredFxStyle shredFxStyleOf(String themeId) {
  switch (themeId) {
    case 'deepAutumn':
      return ShredFxStyle.autumn;
    case 'softDissolve':
      return ShredFxStyle.dissolve;
    case 'clickBird':
      return ShredFxStyle.bird;
    case 'crackFrost':
      return ShredFxStyle.frost;
    case 'snowWhite':
      return ShredFxStyle.snow;
    default:
      return ShredFxStyle.crispy;
  }
}
class ConfettiShredFx extends StatefulWidget {
  final String themeId;
  final String mode;
  final int particleCount;
  const ConfettiShredFx({
    super.key,
    required this.themeId,
    required this.mode,
    required this.particleCount,
  });
  @override
  State<ConfettiShredFx> createState() => _ConfettiShredFxState();
}
class _FxParticle {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final double delay;
  final Color color;
  final int seed;
  final double sway;
  const _FxParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.delay,
    required this.color,
    required this.seed,
    required this.sway,
  });
}
class _ConfettiShredFxState extends State<ConfettiShredFx>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_FxParticle> _particles;
  late ShredFxStyle _style;
  late bool _toZero;
  @override
  void initState() {
    super.initState();
    _style = shredFxStyleOf(widget.themeId);
    _toZero = widget.mode == ConfettiShredMode.everythingToZero;
    final theme = penThemeById(widget.themeId);
    final palette = _paletteOf(_style, theme);
    final rng = Random(theme.id.hashCode);
    _particles = List.generate(widget.particleCount, (i) {
      return _FxParticle(
        angle: rng.nextDouble() * pi * 2,
        speed: 0.18 + rng.nextDouble() * 0.42,
        size: rng.nextDouble() * 12 + 6,
        spin: (rng.nextDouble() - 0.5) * 3.2,
        delay: rng.nextDouble() * 0.22,
        color: palette[rng.nextInt(palette.length)]
            .withOpacity(0.62 + rng.nextDouble() * 0.32),
        seed: rng.nextInt(1 << 16),
        sway: 8 + rng.nextDouble() * 18,
      );
    });
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
        builder: (_, __) => CustomPaint(
          painter: _ShredFxPainter(
            particles: _particles,
            t: _ctrl.value,
            style: _style,
            toZero: _toZero,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
List<Color> _paletteOf(ShredFxStyle style, PenTheme theme) {
  switch (style) {
    case ShredFxStyle.crispy:
      return const [
        Color(0xFFF7F0E8),
        Color(0xFFE85A42),
        Color(0xFFC9A05A),
        Color(0xFFE8D5C4),
      ];
    case ShredFxStyle.autumn:
      return [theme.paper, theme.swatch, theme.ink, const Color(0xFFE8C07A)];
    case ShredFxStyle.dissolve:
      return [theme.paper, theme.swatch, const Color(0xFFE8A0B0), Colors.white];
    case ShredFxStyle.bird:
      return [theme.paper, theme.swatch, theme.ink, const Color(0xFF8FBF92)];
    case ShredFxStyle.frost:
      return [theme.paper, theme.swatch, const Color(0xFF7A9BB8), Colors.white];
    case ShredFxStyle.snow:
      return const [Color(0xFFFFFFFF), Color(0xFFF7F0E8), Color(0xFFE8E4DE)];
  }
}
class _ShredFxPainter extends CustomPainter {
  final List<_FxParticle> particles;
  final double t;
  final ShredFxStyle style;
  final bool toZero;
  _ShredFxPainter({
    required this.particles,
    required this.t,
    required this.style,
    required this.toZero,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, size.height * 0.42);
    if (style == ShredFxStyle.frost) _paintCracks(canvas, origin, size);
    for (final p in particles) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final pos = _position(origin, size, p, local);
      final fade = style == ShredFxStyle.dissolve
          ? (1 - Curves.easeIn.transform(local))
          : (1 - local);
      final paint = Paint()
        ..color = p.color.withOpacity((fade * p.color.a).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;
      if (style == ShredFxStyle.dissolve) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      }
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * local + p.seed * 0.01);
      _drawShape(canvas, p, local, paint);
      canvas.restore();
    }
  }
  Offset _position(Offset origin, Size size, _FxParticle p, double local) {
    final dir = Offset(cos(p.angle), sin(p.angle));
    if (style == ShredFxStyle.dissolve) {
      final grow = toZero ? local * 0.08 : local * 0.16;
      return origin + dir * size.shortestSide * grow;
    }
    if (toZero) {
      final start = p.speed * 0.55;
      final radial = start * (1 - Curves.easeInCubic.transform(local));
      return origin + dir * size.shortestSide * radial;
    }
    var radial = p.speed * Curves.easeOutCubic.transform(local);
    var yExtra = local * local * 0.55;
    if (style == ShredFxStyle.bird) {
      yExtra = -local * 0.72;
      radial = p.speed * 0.85 * local;
    } else if (style == ShredFxStyle.snow) {
      yExtra = local * 0.38;
      radial = p.speed * 0.55 * local;
    } else if (style == ShredFxStyle.autumn) {
      yExtra = local * 0.62;
    }
    final sway = style == ShredFxStyle.autumn || style == ShredFxStyle.snow
        ? sin(local * pi * 3 + p.seed) * p.sway
        : 0.0;
    return Offset(
      origin.dx + dir.dx * size.width * radial + sway,
      origin.dy + dir.dy * size.height * radial * 0.45 + size.height * yExtra,
    );
  }
  void _drawShape(Canvas canvas, _FxParticle p, double local, Paint paint) {
    final s = style == ShredFxStyle.dissolve ? p.size * (1 + local * 1.8) : p.size;
    switch (style) {
      case ShredFxStyle.crispy:
        canvas.drawPath(_scrapPath(s, p.seed), paint);
      case ShredFxStyle.autumn:
        canvas.drawPath(_leafPath(s), paint);
      case ShredFxStyle.dissolve:
        canvas.drawCircle(Offset.zero, s, paint);
      case ShredFxStyle.bird:
        canvas.drawPath(_birdPath(s), paint);
      case ShredFxStyle.frost:
        canvas.drawPath(_shardPath(s), paint);
      case ShredFxStyle.snow:
        _drawSnowflake(canvas, s, paint);
    }
  }
  Path _scrapPath(double s, int seed) {
    final rng = Random(seed);
    final path = Path();
    const n = 5;
    for (var i = 0; i < n; i++) {
      final a = (i / n) * pi * 2 + rng.nextDouble() * 0.4;
      final r = s * (0.45 + rng.nextDouble() * 0.55);
      final p = Offset(cos(a) * r, sin(a) * r * 0.7);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }
  Path _leafPath(double s) {
    return Path()
      ..moveTo(0, -s)
      ..cubicTo(s * 0.7, -s * 0.4, s * 0.7, s * 0.3, 0, s)
      ..cubicTo(-s * 0.7, s * 0.3, -s * 0.7, -s * 0.4, 0, -s)
      ..close();
  }
  Path _birdPath(double s) {
    return Path()
      ..moveTo(-s, 0)
      ..quadraticBezierTo(-s * 0.2, -s * 0.55, 0, 0)
      ..quadraticBezierTo(s * 0.2, -s * 0.55, s, 0)
      ..quadraticBezierTo(s * 0.15, -s * 0.15, 0, s * 0.12)
      ..quadraticBezierTo(-s * 0.15, -s * 0.15, -s, 0)
      ..close();
  }
  Path _shardPath(double s) {
    return Path()
      ..moveTo(0, -s)
      ..lineTo(s * 0.38, 0)
      ..lineTo(0, s * 0.7)
      ..lineTo(-s * 0.32, 0)
      ..close();
  }
  void _drawSnowflake(Canvas canvas, double s, Paint paint) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * pi / 3;
      final tip = Offset(cos(a) * s, sin(a) * s);
      canvas.drawLine(Offset.zero, tip, paint);
      final mid = tip * 0.55;
      canvas.drawLine(
        mid,
        mid + Offset(cos(a + 0.7) * s * 0.28, sin(a + 0.7) * s * 0.28),
        paint,
      );
    }
  }
  void _paintCracks(Canvas canvas, Offset origin, Size size) {
    final crackT = (t / 0.38).clamp(0.0, 1.0);
    if (crackT <= 0) return;
    final paint = Paint()
      ..color = const Color(0xFFD7E6F4).withOpacity(0.55 * (1 - t * 0.7))
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    final rng = Random(7);
    for (var i = 0; i < 10; i++) {
      final a = rng.nextDouble() * pi * 2;
      final len = size.shortestSide * (0.18 + rng.nextDouble() * 0.28) * crackT;
      canvas.drawLine(
        origin,
        origin + Offset(cos(a) * len, sin(a) * len),
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _ShredFxPainter old) =>
      old.t != t || old.style != style || old.toZero != toZero;
}

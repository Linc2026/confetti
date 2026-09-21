import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/confetti_fonts.dart';
import '../utils/app_colors.dart';
import 'confetti_shred_fx.dart';
class ConfettiWordBurst extends StatefulWidget {
  final List<String> words;
  const ConfettiWordBurst({super.key, required this.words});
  @override
  State<ConfettiWordBurst> createState() => _ConfettiWordBurstState();
}
class _ChipFlight {
  final String word;
  final double startAngle;
  final double startRadius;
  final Offset gatherNudge;
  const _ChipFlight({
    required this.word,
    required this.startAngle,
    required this.startRadius,
    required this.gatherNudge,
  });
}
class _LetterFlight {
  final String letter;
  final double angle;
  final double speed;
  final double spin;
  final double delay;
  final double size;
  final Color color;
  final Offset gatherNudge;
  const _LetterFlight({
    required this.letter,
    required this.angle,
    required this.speed,
    required this.spin,
    required this.delay,
    required this.size,
    required this.color,
    required this.gatherNudge,
  });
}
class _ConfettiWordBurstState extends State<ConfettiWordBurst>
    with SingleTickerProviderStateMixin {
  static const _palette = [
    Color(0xFFE85A42),
    Color(0xFF3A8A76),
    Color(0xFFC9A05A),
    Color(0xFF2A2620),
    Color(0xFFF7F0E8),
  ];
  late final AnimationController _ctrl;
  late final List<_ChipFlight> _chips;
  late final List<_LetterFlight> _letters;
  @override
  void initState() {
    super.initState();
    final rng = Random(widget.words.join().hashCode);
    _chips = List.generate(widget.words.length, (i) {
      return _ChipFlight(
        word: widget.words[i],
        startAngle: (i / max(widget.words.length, 1)) * pi * 2 +
            rng.nextDouble() * 0.4,
        startRadius: 0.22 + rng.nextDouble() * 0.18,
        gatherNudge: Offset(
          (rng.nextDouble() - 0.5) * 36,
          (rng.nextDouble() - 0.5) * 28,
        ),
      );
    });
    _letters = [
      for (final chip in _chips)
        for (var i = 0; i < chip.word.length; i++)
          if (chip.word[i].trim().isNotEmpty)
            _LetterFlight(
              letter: chip.word[i],
              angle: rng.nextDouble() * pi * 2,
              speed: 0.22 + rng.nextDouble() * 0.5,
              spin: (rng.nextDouble() - 0.5) * 4.2,
              delay: 0.2 + rng.nextDouble() * 0.12,
              size: 13 + rng.nextDouble() * 7,
              color: _palette[rng.nextInt(_palette.length)],
              gatherNudge: chip.gatherNudge,
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
              final origin = Offset(size.width * 0.5, size.height * 0.42);
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    size: size,
                    painter: _LetterBurstPainter(letters: _letters, t: t),
                  ),
                  if (t < 0.46)
                    ..._chips.map((chip) => _buildChip(chip, origin, size, t)),
                ],
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildChip(_ChipFlight chip, Offset origin, Size size, double t) {
    final gather = Curves.easeOutCubic.transform((t / 0.28).clamp(0.0, 1.0));
    final burst = ((t - 0.22) / 0.24).clamp(0.0, 1.0);
    final start = origin +
        Offset(cos(chip.startAngle), sin(chip.startAngle)) *
            size.shortestSide *
            chip.startRadius;
    final pos = Offset.lerp(start, origin + chip.gatherNudge, gather)!;
    final opacity = t < 0.06
        ? t / 0.06
        : (1 - Curves.easeIn.transform(burst)).clamp(0.0, 1.0);
    final scale = 0.82 + gather * 0.2 + burst * 0.38;
    return Positioned(
      left: pos.dx - 60.w,
      top: pos.dy - 16.h,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              chip.word,
              style: ConfettiFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _LetterBurstPainter extends CustomPainter {
  final List<_LetterFlight> letters;
  final double t;
  _LetterBurstPainter({required this.letters, required this.t});
  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width * 0.5, size.height * 0.42);
    for (final p in letters) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final dir = Offset(cos(p.angle), sin(p.angle));
      final radial = p.speed * Curves.easeOutCubic.transform(local);
      final pos = Offset(
        origin.dx + p.gatherNudge.dx + dir.dx * size.width * radial,
        origin.dy +
            p.gatherNudge.dy +
            dir.dy * size.height * radial * 0.45 +
            size.height * local * local * 0.42,
      );
      final fade = (1 - local).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: p.letter,
          style: TextStyle(
            fontSize: p.size,
            fontWeight: FontWeight.w700,
            color: p.color.withOpacity(fade * 0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * local);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant _LetterBurstPainter old) => old.t != t;
}

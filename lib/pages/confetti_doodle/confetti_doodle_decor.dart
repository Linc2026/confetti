import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/app_colors.dart';
class DoodlePaperGrain extends StatelessWidget {
  const DoodlePaperGrain({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: CustomPaint(painter: _GrainPainter()),
    );
  }
}
class _GrainPainter extends CustomPainter {
  const _GrainPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(26);
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 90; i++) {
      paint.color = Color.fromRGBO(42, 38, 31, 0.028 + rng.nextDouble() * 0.03);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        0.6 + rng.nextDouble() * 1.1,
        paint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class DoodleCornerFold extends StatelessWidget {
  const DoodleCornerFold({super.key});
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _FoldPainter()));
  }
}
class _FoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = 22.0;
    final path = Path()
      ..moveTo(size.width - s, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, s)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE8D9A8));
    canvas.drawLine(
      Offset(size.width - s, 0),
      Offset(size.width, s),
      Paint()
        ..color = const Color(0xFF2A261F).withOpacity(0.08)
        ..strokeWidth = 1,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class DoodleInkTicks extends StatelessWidget {
  final int inkWeight;
  const DoodleInkTicks({super.key, required this.inkWeight});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final on = inkWeight >= i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: i == inkWeight && inkWeight > 0 ? 16.w : 10.w,
          height: 3.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: on
                ? AppColors.onDestroy.withOpacity(0.55 + i * 0.12)
                : AppColors.onDestroy.withOpacity(0.12),
            borderRadius: BorderRadius.circular(2.r),
          ),
        );
      }),
    );
  }
}

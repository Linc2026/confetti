import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/confetti_fonts.dart';
import '../utils/app_colors.dart';
class TornPaperClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.01, h * 0.08);
    path.lineTo(w * 0.03, h * 0.02);
    path.lineTo(w * 0.10, h * 0.05);
    path.lineTo(w * 0.18, h * 0.00);
    path.lineTo(w * 0.32, h * 0.04);
    path.lineTo(w * 0.50, h * 0.01);
    path.lineTo(w * 0.68, h * 0.04);
    path.lineTo(w * 0.82, h * 0.00);
    path.lineTo(w * 0.92, h * 0.05);
    path.lineTo(w * 0.98, h * 0.02);
    path.lineTo(w * 1.00, h * 0.10);
    path.lineTo(w * 0.99, h * 0.50);
    path.lineTo(w * 1.00, h * 0.90);
    path.lineTo(w * 0.96, h * 0.99);
    path.lineTo(w * 0.82, h * 0.96);
    path.lineTo(w * 0.68, h * 1.00);
    path.lineTo(w * 0.50, h * 0.97);
    path.lineTo(w * 0.32, h * 1.00);
    path.lineTo(w * 0.18, h * 0.96);
    path.lineTo(w * 0.06, h * 1.00);
    path.lineTo(w * 0.00, h * 0.90);
    path.lineTo(w * 0.01, h * 0.50);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
class ConfettiBtnStamp extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool dark;
  final double? fontSize;
  final EdgeInsets? padding;
  final double? width;
  const ConfettiBtnStamp({
    super.key,
    required this.text,
    this.onTap,
    this.onLongPress,
    this.dark = false,
    this.fontSize,
    this.padding,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    final bgColor = dark ? AppColors.destroy : AppColors.primary;
    final fSize = (fontSize ?? 16).sp;
    final pad = padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: width,
        child: ClipPath(
          clipper: TornPaperClipper(),
          child: Container(
            padding: pad,
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: dark
                  ? [
                      BoxShadow(
                        color: const Color(0xFF1C1917).withOpacity(0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.32),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: const Color(0xFFB43C28).withOpacity(0.4),
                        blurRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              text,
              style: ConfettiFonts.outfit(
                fontSize: fSize,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.2,
                height: 1.15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
class ConfettiBtnGhost extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? fontSize;
  const ConfettiBtnGhost({super.key, required this.text, this.onTap, this.fontSize});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.destroyHighlight,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          text,
          style: ConfettiFonts.outfit(
            fontSize: (fontSize ?? 12).sp,
            fontWeight: FontWeight.w600,
            color: AppColors.onDestroy,
          ),
        ),
      ),
    );
  }
}

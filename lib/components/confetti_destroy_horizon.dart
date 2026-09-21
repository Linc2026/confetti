import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ConfettiDestroyHorizon extends StatelessWidget {
  final Widget child;
  final double? height;
  final bool lightHomeBar;
  const ConfettiDestroyHorizon({
    super.key,
    required this.child,
    this.height,
    this.lightHomeBar = false,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 148.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.32, 0.72, 1.0],
          colors: [
            Color(0x001E1B18),
            Color(0x8C1E1B18),
            Color(0xFF1E1B18),
            Color(0xFF1E1B18),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFF3A322C),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Expanded(child: child),
          Container(
            width: 134.w,
            height: 5.h,
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: lightHomeBar
                  ? const Color(0xFF1C1917).withOpacity(0.14)
                  : const Color(0xFFF7F0E8).withOpacity(0.16),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ],
      ),
    );
  }
}

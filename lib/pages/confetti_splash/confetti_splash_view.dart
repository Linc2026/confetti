import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import 'confetti_splash_logic.dart';
class ConfettiSplashView extends GetView<ConfettiSplashLogic> {
  const ConfettiSplashView({super.key});
  @override
  Widget build(BuildContext context) {
    controller;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/illustrations/ill_splash.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.76),
          ),
          Positioned(
            top: 200.h,
            left: 50.w,
            width: 220.w,
            child: Text(
              'Write your emotions,\nlet them disappear',
              textAlign: TextAlign.center,
              style: ConfettiFonts.fraunces(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Positioned(
            bottom: 46.h,
            right: 27.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _privacyText('No traces'),
                SizedBox(height: 6.h),
                _privacyText('No upload'),
                SizedBox(height: 6.h),
                _privacyText('Words stay in memory'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _privacyText(String text) {
    return Text(
      text,
      style: ConfettiFonts.outfit(
        fontSize: 11.sp,
        letterSpacing: 0.6,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

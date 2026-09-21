import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import 'confetti_about_logic.dart';
class ConfettiAboutView extends GetView<ConfettiAboutLogic> {
  const ConfettiAboutView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHero(),
              Expanded(child: _buildScrollContent()),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            child: _buildBackBtn(),
          ),
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 134.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHero() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/illustrations/ill_splash.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.64),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.62, 1.0],
                colors: [
                  Color(0x00FFF8F2),
                  Color(0xFFFFF8F2),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(22.w, 96.h, 22.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleSection(),
              SizedBox(height: 18.h),
              _buildDescriptionCard(),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildBackBtn() {
    return GestureDetector(
      onTap: controller.onBackTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.82),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.chevron_left_rounded,
          size: 22.r,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
  Widget _buildScrollContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 80.h),
      child: Column(
        children: [
          _buildSectionLabel('Privacy Promise'),
          SizedBox(height: 8.h),
          _buildPrivacyCard(),
          SizedBox(height: 18.h),
          _buildSectionLabel('Connect'),
          SizedBox(height: 8.h),
          _buildConnectCard(),
          SizedBox(height: 22.h),
          Text(
            '© 2026 Confetti. All rights reserved.',
            textAlign: TextAlign.center,
            style: ConfettiFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.textDisabled,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Confetti',
          style: ConfettiFonts.fraunces(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Write your emotions, let them disappear',
          style: ConfettiFonts.fraunces(
            fontStyle: FontStyle.italic,
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => Text(
          controller.appVersion.value,
          style: ConfettiFonts.outfit(
            fontSize: 12.sp,
            color: AppColors.textTertiary,
          ),
        )),
      ],
    );
  }
  Widget _buildDescriptionCard() {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1917).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "Confetti is a private space to write down what's weighing on you — then destroy it completely. No saving, no history, no traces. Just the act of letting go.",
        style: ConfettiFonts.outfit(
          fontSize: 14.sp,
          height: 1.7,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: ConfettiFonts.outfit(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
  Widget _buildPrivacyCard() {
    final items = [
      _PrivacyItem(
        isCheck: false,
        title: 'No internet connection required',
        sub: 'Works completely offline',
      ),
      _PrivacyItem(
        isCheck: false,
        title: 'No server. No cloud. No account.',
        sub: 'Fully self-contained on your device',
      ),
      _PrivacyItem(
        isCheck: false,
        title: 'Your words are never stored or uploaded.',
        sub: 'Text only lives in memory during your session',
      ),
      _PrivacyItem(
        isCheck: true,
        title: 'Everything you write is destroyed when you shred it.',
        sub: 'Permanently gone the moment you release it',
      ),
      _PrivacyItem(
        isCheck: true,
        title: 'Local habits only: shred mode, quotes, last theme.',
        sub: 'Anonymous preferences stay on this device',
        isLast: true,
      ),
    ];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1917).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map(_buildPrivacyRow).toList(),
      ),
    );
  }
  Widget _buildPrivacyRow(_PrivacyItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: item.isLast
            ? null
            : Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              color: item.isCheck ? AppColors.secondaryLight : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                item.isCheck ? '✓' : '×',
                style: ConfettiFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: item.isCheck ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: ConfettiFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.sub,
                  style: ConfettiFonts.outfit(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildConnectCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1917).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: controller.onRateTap,
        child: _buildConnectRow(
          title: 'Love Confetti? Rate us',
          sub: GetPlatform.isIOS
              ? 'Rate on the App Store'
              : 'Rate on Google Play',
          isLast: true,
        ),
      ),
    );
  }
  Widget _buildConnectRow({
    required String title,
    required String sub,
    required bool isLast,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 13.h),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ConfettiFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                sub,
                style: ConfettiFonts.outfit(
                  fontSize: 12.sp,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18.r,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
class _PrivacyItem {
  final bool isCheck;
  final String title;
  final String sub;
  final bool isLast;
  const _PrivacyItem({
    required this.isCheck,
    required this.title,
    required this.sub,
    this.isLast = false,
  });
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../db_confetti/db_confetti_entity.dart';
import '../../utils/app_colors.dart';
import '../../components/confetti_btn_stamp.dart';
import '../../components/confetti_shred_fx.dart';
import 'confetti_home_logic.dart';
import 'confetti_home_pen_sheet.dart';
class ConfettiHomeView extends GetView<ConfettiHomeLogic> {
  const ConfettiHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/illustrations/ill_home.png', fit: BoxFit.cover),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: controller.openLastMode,
            ),
          ),
          _buildTopRow(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomCluster(),
          ),
          Obx(() => controller.showPenSelector.value
              ? const ConfettiHomePenSheet()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
  Widget _buildTopRow() {
    return Positioned(
      top: 57.h,
      left: 15.w,
      right: 15.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildModes()),
          SizedBox(width: 10.w),
          _buildAboutBtn(),
        ],
      ),
    );
  }
  Widget _buildModes() {
    return _paperChip(
      radius: 22.r,
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: Obx(() => Row(
          children: [
            _buildModeBtn(0, 'Physical', 'Degradation', 'Tears into pieces'),
            SizedBox(width: 4.w),
            _buildModeBtn(
              1,
              'Everything',
              'Returns to Zero',
              'Dissolves into nothing',
            ),
          ],
        )),
      ),
    );
  }
  Widget _paperChip({required double radius, required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F2).withOpacity(0.78),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xFFE9DFD6).withOpacity(0.7)),
          ),
          child: child,
        ),
      ),
    );
  }
  Widget _buildModeBtn(int index, String line1, String line2, String sub) {
    final isOn = controller.selectedMode.value == index;
    final previewing = isOn && controller.modePreviewToken.value > 0;
    final mode = index == 1
        ? ConfettiShredMode.everythingToZero
        : ConfettiShredMode.physicalDegradation;
    final titleColor = isOn ? Colors.white : AppColors.textSecondary;
    final subColor = isOn
        ? Colors.white.withOpacity(0.78)
        : AppColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectMode(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      line1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ConfettiFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      line2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ConfettiFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ConfettiFonts.outfit(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w500,
                        color: subColor,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                if (previewing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ConfettiShredFx(
                        key: ValueKey(controller.modePreviewToken.value),
                        themeId: 'crispyBlank',
                        mode: mode,
                        particleCount: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildAboutBtn() {
    return GestureDetector(
      onTap: controller.goAbout,
      child: _paperChip(
        radius: 20.r,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(
            Icons.info_outline_rounded,
            size: 18.r,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
  Widget _buildCta() {
    return Column(
      children: [
        ConfettiBtnStamp(
          text: '—— Open a note ——',
          fontSize: 18,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
          width: double.infinity,
          onTap: controller.openNote,
          onLongPress: controller.openLastNote,
        ),
        SizedBox(height: 10.h),
        Center(
          child: _paperChip(
            radius: 20.r,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
              child: Obx(() => Text(
                controller.ctaHint,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ConfettiFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              )),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildTools() {
    return Obx(() {
      final fuses = controller.countdownCompletions.value;
      final rec = controller.recommendedTool;
      final tools = [
        (
          'Doodle',
          'assets/illustrations/ill_doodle.png',
          controller.goDoodle,
          null,
          'doodle',
        ),
        (
          'Word Jar',
          'assets/illustrations/ill_word_jar.png',
          controller.goWordJar,
          null,
          'wordJar',
        ),
        (
          'Rage Tap',
          'assets/illustrations/ill_rage_tap.png',
          controller.goRageTap,
          null,
          'rageTap',
        ),
        (
          'Countdown',
          'assets/illustrations/ill_countdown.png',
          controller.goCountdown,
          fuses > 0 ? '$fuses fuses' : null,
          'countdown',
        ),
      ];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tools
            .map(
              (t) => _buildTool(
                t.$1,
                t.$2,
                t.$3,
                subtitle: t.$4,
                recommended: rec == t.$5,
              ),
            )
            .toList(),
      );
    });
  }
  Widget _buildTool(
    String label,
    String assetPath,
    VoidCallback onTap, {
    String? subtitle,
    bool recommended = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80.w,
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: recommended
                      ? AppColors.secondary.withOpacity(0.85)
                      : const Color(0xFFFFF8F2).withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  if (recommended)
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  BoxShadow(
                    color: const Color(0xFF1C1917).withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.5.r),
                child: Image.asset(assetPath, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 7.h),
            SizedBox(
              height: 28.h,
              child: Column(
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ConfettiFonts.outfit(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF7F0E8),
                      height: 1.15,
                      shadows: const [
                        Shadow(
                          color: Color(0x73000000),
                          offset: Offset(0, 1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null || recommended)
                    Text(
                      subtitle ?? 'for you',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ConfettiFonts.outfit(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: recommended
                            ? const Color(0xFFD8EFE8)
                            : const Color(0xFFF7F0E8).withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildBottomCluster() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.22, 0.62, 1.0],
          colors: [
            Color(0x001E1B18),
            Color(0x8C1E1B18),
            Color(0xFF1E1B18),
            Color(0xFF1E1B18),
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(19.w, 8.h, 19.w, 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _buildCta(),
          ),
          SizedBox(height: 18.h),
          _buildTools(),
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.destroyHighlight,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'CONFETTI',
            style: ConfettiFonts.outfit(
              fontSize: 10.sp,
              letterSpacing: 3,
              color: AppColors.destroyHighlight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 134.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F0E8).withOpacity(0.16),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ],
      ),
    );
  }
}

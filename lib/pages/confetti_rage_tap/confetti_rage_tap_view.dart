import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import '../../components/confetti_btn_stamp.dart';
import '../../components/confetti_release_flow.dart';
import 'confetti_rage_tap_decor.dart';
import 'confetti_rage_tap_logic.dart';
class ConfettiRageTapView extends GetView<ConfettiRageTapLogic> {
  const ConfettiRageTapView({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.onDiscardTap();
      },
      child: ConfettiReleaseHost(
        controller: controller,
        child: Scaffold(
          backgroundColor: const Color(0xFF2A221C),
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildImpactStage(),
              Positioned(
                top: MediaQuery.of(context).padding.top + 4.h,
                left: 18.w,
                right: 18.w,
                child: _buildTopBar(),
              ),
              Center(
                child: IgnorePointer(
                  child: Obx(() => AnimatedOpacity(
                    opacity: controller.hitCount.value > 0 ? 0 : 1,
                    duration: const Duration(milliseconds: 280),
                    child: Text(
                      'TAP ANYWHERE',
                      style: ConfettiFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        color: const Color(0xFF1C1917).withOpacity(0.28),
                      ),
                    ),
                  )),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildDestroyZone(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildImpactStage() {
    return Obx(() {
      final gen = controller.shakeGen.value;
      return TweenAnimationBuilder<double>(
        key: ValueKey(gen),
        tween: Tween(begin: gen == 0 ? 0 : 1, end: 0),
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        builder: (_, t, child) => Transform.translate(
          offset: Offset((gen.isOdd ? 1 : -1) * 5 * t, -3 * t),
          child: child,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/illustrations/ill_rage_tap.png',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [
                    Color(0x471E1B18),
                    Color(0x1F1E1B18),
                    Color(0x8C1E1B18),
                  ],
                ),
              ),
            ),
            _buildTapLayer(),
          ],
        ),
      );
    });
  }
  Widget _buildTapLayer() {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) => controller.onTap(e.localPosition),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (d) => controller.onLongPressStart(d.localPosition),
        onLongPressEnd: (_) => controller.onLongPressEnd(),
        onLongPressCancel: () => controller.onLongPressEnd(),
        child: Obx(() => RageTapFxCanvas(
          ripples: List<RippleData>.from(controller.ripples),
          dots: List<Offset>.from(controller.heatDots),
          cracks: List<CrackImpact>.from(controller.cracks),
        )),
      ),
    );
  }
  Widget _buildTopBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HITS',
              style: ConfettiFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppColors.onDestroy.withOpacity(0.7),
              ),
            ),
            Obx(() {
              final n = controller.hitCount.value;
              return TweenAnimationBuilder<double>(
                key: ValueKey(n),
                tween: Tween(begin: n == 0 ? 1 : 1.22, end: 1),
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOutBack,
                builder: (_, s, child) => Transform.scale(scale: s, child: child),
                child: Text(
                  '×$n',
                  style: ConfettiFonts.fraunces(
                    fontSize: 44.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: -1.5,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: AppColors.primary.withOpacity(0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 6.h),
            Obx(() => RageTapHeatTicks(heatLevel: controller.heatLevel.value)),
          ],
        ),
        GestureDetector(
          onTap: controller.onDiscardTap,
          child: Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F2).withOpacity(0.18),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.close,
              size: 13.r,
              color: const Color(0xFFF7F0E8),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDestroyZone() {
    return Container(
      height: 148.h,
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
              color: AppColors.destroyHighlight,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
            controller.coachLine,
            style: ConfettiFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.onDestroyMuted,
            ),
          )),
          SizedBox(height: 8.h),
          Obx(() => Opacity(
            opacity: controller.hitCount.value > 0 ? 1 : 0.38,
            child: ConfettiBtnStamp(
              text: 'Release it',
              fontSize: 15,
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
              onTap: controller.release,
            ),
          )),
          const Spacer(),
          Container(
            width: 134.w,
            height: 5.h,
            margin: EdgeInsets.only(bottom: 8.h),
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

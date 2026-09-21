import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../models/pen_theme.dart';
import '../../utils/app_colors.dart';
import '../../utils/confetti_fonts.dart';
import '../../components/confetti_paper_fill.dart';
import 'confetti_home_logic.dart';
class ConfettiHomePenSheet extends GetView<ConfettiHomeLogic> {
  const ConfettiHomePenSheet({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.closePenSelector,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          color: const Color(0x7A1E1B18),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              onVerticalDragUpdate: (d) =>
                  controller.onPenSheetDragUpdate(d.delta.dy),
              onVerticalDragEnd: (_) => controller.onPenSheetDragEnd(),
              child: Obx(() => Transform.translate(
                offset: Offset(0, controller.penSheetOffset.value),
                child: _buildPenSheet(),
              )),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildPenSheet() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF9),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C1917).withOpacity(0.22),
            blurRadius: 50,
            offset: const Offset(0, -16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36.r),
          topRight: Radius.circular(36.r),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/illustrations/ill_write.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 14.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 28.w,
                    vertical: 18.h,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '—— Choose your pen ——',
                        style: ConfettiFonts.fraunces(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.04 * 18,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Select a theme for your note',
                        style: ConfettiFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w),
                  child: Column(
                    children: [
                      _buildThemeRow(0, 3),
                      SizedBox(height: 22.h),
                      _buildThemeRow(3, 6),
                    ],
                  ),
                ),
                SizedBox(height: 36.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildThemeRow(int start, int end) {
    final themes = kPenThemes.sublist(start, end);
    return Row(
      children: themes
          .map(
            (t) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: _buildThemeItem(t),
              ),
            ),
          )
          .toList(),
    );
  }
  Widget _buildThemeItem(PenTheme theme) {
    return Obx(() {
      final last = controller.lastThemeId.value == theme.id;
      return GestureDetector(
        onTap: () => controller.onThemeTap(theme.id),
        child: Column(
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: last
                      ? AppColors.primary
                      : const Color(0xFF1C1917).withOpacity(0.06),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C1917).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.5.r),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ConfettiPaperFill(asset: theme.paperImage),
                    ),
                    Positioned(
                      left: 10.w,
                      right: 14.w,
                      bottom: 10.h,
                      child: Column(
                        children: List.generate(3, (i) {
                          return Container(
                            height: 1.5.h,
                            width: i == 2 ? 28.w : double.infinity,
                            margin: EdgeInsets.only(bottom: i == 2 ? 0 : 3.h),
                            color: theme.ink.withOpacity(0.28),
                          );
                        }),
                      ),
                    ),
                    if (last)
                      Positioned(
                        top: 5.h,
                        right: 5.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Last',
                            style: ConfettiFonts.outfit(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              theme.name,
              style: ConfettiFonts.outfit(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: last ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }
}

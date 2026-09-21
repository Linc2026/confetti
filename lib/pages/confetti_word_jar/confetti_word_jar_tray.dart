import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../utils/confetti_fonts.dart';
import '../../utils/app_colors.dart';
import 'confetti_word_jar_logic.dart';
class ConfettiWordJarTray extends StatelessWidget {
  final ConfettiWordJarLogic controller;
  const ConfettiWordJarTray({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = controller.selectedEntries;
      if (entries.isEmpty) return const SizedBox.shrink();
      return Container(
        height: 36.h,
        margin: EdgeInsets.only(bottom: 10.h),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: entries.length,
          separatorBuilder: (_, _) => SizedBox(width: 4.w),
          itemBuilder: (_, i) {
            final pick = entries[i];
            final custom = pick.category == ConfettiWordJarLogic.customCategory;
            return GestureDetector(
              onTap: () => controller.toggleWord(pick.category, pick.word),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: custom ? AppColors.secondaryLight : AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pick.word,
                      style: ConfettiFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: custom ? const Color(0xFF2A6B5C) : Colors.white,
                      ),
                    ),
                    if (custom) ...[
                      SizedBox(width: 4.w),
                      Text(
                        'Custom',
                        style: ConfettiFonts.outfit(
                          fontSize: 8.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
